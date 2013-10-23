%regex{ (** FIXME remove duplication later see lexing_util.cmo *)
let newline = ('\010' | '\013' | "\013\010")
let ocaml_blank = [' ' '\009' '\012']
let lowercase = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']
let uppercase = ['A'-'Z' '\192'-'\214' '\216'-'\222']
let identchar = ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9']
let ident = (lowercase|uppercase) identchar*
let locname = ident
let hexa_char = ['0'-'9' 'A'-'F' 'a'-'f']
let ocaml_escaped_char =
  '\\'
    (['\\' '"' 'n' 't' 'b' 'r' ' ' '\'']
     | ['0'-'9'] ['0'-'9'] ['0'-'9']
     |'x' hexa_char hexa_char)
let ocaml_char =
  ( [^ '\\' '\010' '\013'] | ocaml_escaped_char)
let ocaml_lid =  lowercase identchar *
let ocaml_uid =  uppercase identchar * 
};;


(*************************************)
(*    local operators                *)    
(*************************************)        
let (++) = Buffer.add_string       
let (+>) = Buffer.add_char
(** get the location of current the lexeme *)
let (!!)  = Location_util.from_lexbuf ;;

(* let opt_char_len = Lexing_util;; *)
%import{
Lexing_util:
  update_loc
  new_cxt
  push_loc_cont
  pop_loc
  lex_string
  lex_comment
  lex_quotation
  lex_antiquot
  buff_contents
  err
  warn
  move_curr_p
  store
  lexing_store
  with_store
  ;
Location_util:
   (--)
   ;
};;    


let  rec token : Lexing.lexbuf -> (Tokenf.t * Locf.t ) = %lex{
  | newline as txt %{
    begin
      update_loc  lexbuf;
      let loc = !! lexbuf in
      (`Newline {loc;txt},loc)
    end}
  | ocaml_lid as txt %{let loc = !!lexbuf in (`Lid {loc;txt},loc )}
  | '"' %{
    let c = new_cxt ()  in
    let old = lexbuf.lex_start_p in
    begin
      push_loc_cont c lexbuf lex_string;
      let loc = old --  lexbuf.lex_curr_p in
      (`Str {loc; txt =buff_contents c},loc)
    end}
  | "'" (newline as txt) "'" %{
    begin
      update_loc   lexbuf ~retract:1;
      let loc = !!lexbuf in
      (`Chr {loc;txt}, loc)
    end}

  | "'" (ocaml_char as txt ) "'" %{
    let loc = !!lexbuf in (`Chr {loc;txt} , loc )}

  | "'\\" (_ as c) %{err (Illegal_escape (String.make 1 c)) @@ !! lexbuf}

  | "#" | "|" | "^" | "<" | "->" |"="  |"_" | "*" | "["
  |"]" | "*" | "?" | "+" | "(" | ")" | "-" as txt %{
    let loc = !! lexbuf in (`Sym {loc;txt},loc )}

  | ocaml_blank + %{ token lexbuf }

  | "(*"(')' as x) ? %{
    let c = new_cxt () in
    begin
      if x <> None then warn Comment_start (!! lexbuf);
      store c lexbuf;
      push_loc_cont c lexbuf lex_comment;
      token lexbuf 
    end}
      (* quotation handling *)
  | "%{" %{
    let old = lexbuf.lex_start_p in
    let c = new_cxt () in
    begin
      store c lexbuf;
      push_loc_cont c lexbuf lex_quotation;
      let loc = old -- lexbuf.lex_curr_p in
      (`Quot {Tokenf.name=Tokenf.empty_name;
              meta=None;
              content = buff_contents c ;
              shift = 2;
              retract = 1;
              loc},loc)
    end}
  | eof %{
      let pos = lexbuf.lex_curr_p in (* FIXME *)
      (lexbuf.lex_curr_p <-
      { pos with pos_bol  = pos.pos_bol  + 1 ;
        pos_cnum = pos.pos_cnum + 1 };
       let loc = !!lexbuf in
       (`EOI {loc;txt=""},  loc))}
    
  | _ as c %{ err (Illegal_character c) @@  !!lexbuf }}
    

let from_lexbuf lb = Streamf.from (fun _ -> Some (token lb))

let from_stream (loc:Locf.t) strm =
  let lb = Lexing.from_function (lexing_store strm) in begin
    lb.lex_abs_pos <- loc.loc_start.pos_cnum;
    lb.lex_curr_p <- loc.loc_start;
    from_lexbuf  lb
  end

(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/lex_lex.cmo" *)
(* end: *)
