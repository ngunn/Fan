

%regex{ (** FIXME remove duplication later see lexing_util.cmo *)
let locname = ident

};;


(*************************************)
(*    local operators                *)    
(*************************************)        
let (++) = Buffer.add_string       
let (+>) = Buffer.add_char
(** get the location of current the lexeme *)
let (!!)  = Location_util.from_lexbuf ;;


%import{
Lexing_util:
  update_loc
  new_cxt
  push_loc_cont
  pop_loc
  lex_string
  lex_comment
  lex_quotation
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


let  rec token = %lex_fan{
  | @whitespace %{token lexbuf}
  | ocaml_lid as txt %{let loc = !!lexbuf in `Lid {loc;txt}}
  | @ocaml_char
  | @ocaml_string
  | "#" | "|" | "^" | "<" | "->" |"="  |"_" | "*" | "["
  |"]" | "*" | "?" | "+" | "(" | ")" | "-" | "@" as txt %{
    let loc = !! lexbuf in `Sym {loc;txt}}
  | @ocaml_comment %{token lexbuf} (* FIXME error message, location *)
      (* quotation handling *)
  | @ocaml_simple_quotation
  | @ocaml_eof
  | @default}
    

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
