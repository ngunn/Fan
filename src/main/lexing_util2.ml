

(** FIXME, some should be pre-registered, and unused regex warnings are preferred  *)
{:regexp|
let newline = ('\010' | '\013' | "\013\010")
let ocaml_blank = [' ' '\009' '\012']
let lowercase = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']
let uppercase = ['A'-'Z' '\192'-'\214' '\216'-'\222']
let identchar = ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9']
let ident = (lowercase|uppercase) identchar*
    
let quotation_name = '.' ? (uppercase  identchar* '.') *
    (lowercase (identchar | '-') * )

let locname = ident

let quotation_prefix = "%" quotation_name  "{"

    

let lident = lowercase identchar *
let antifollowident =   identchar +   
let uident = uppercase identchar *
let not_star_symbolchar =
  [(* '$' *) '!' '%' '&' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '|' '~' '\\']
let symbolchar = '*' | not_star_symbolchar
let quotchar =
  ['!' '%' '&' '+' '-' '.' '/' ':' '=' '?' '@' '^' '|' '~' '\\' '*']
let extra_quot =
  ['!' '%' '&' '+' '-' '.' '/' ':' '=' '?' '@' '^'  '~' '\\']
    (* FIX remove the '\' as extra quot*)
let hexa_char = ['0'-'9' 'A'-'F' 'a'-'f']
let decimal_literal =
  ['0'-'9'] ['0'-'9' '_']*
let hex_literal =
  '0' ['x' 'X'] hexa_char ['0'-'9' 'A'-'F' 'a'-'f' '_']*
let oct_literal =
  '0' ['o' 'O'] ['0'-'7'] ['0'-'7' '_']*
let bin_literal =
  '0' ['b' 'B'] ['0'-'1'] ['0'-'1' '_']*
let int_literal =
  decimal_literal | hex_literal | oct_literal | bin_literal
let float_literal =
  ['0'-'9'] ['0'-'9' '_']*
    ('.' ['0'-'9' '_']* )?
    (['e' 'E'] ['+' '-']? ['0'-'9'] ['0'-'9' '_']* )?
  
(* Delimitors are extended (from 3.09) in a conservative way *)

(* These chars that can't start an expession or a pattern: *)
let safe_delimchars = ['%' '&' '/' '@' '^']
    
(* These symbols are unsafe since "[<", "[|", etc. exsist. *)
let delimchars = safe_delimchars | ['|' '<' '>' ':' '=' '.']

let left_delims  = ['(' '[' ]
let right_delims = [')' ']' ]
    
let left_delimitor = (* At least a safe_delimchars *)
  left_delims delimchars* safe_delimchars (delimchars|left_delims)*
   (* A '(' or a new super '(' without "(<" *)
  | '(' (['|' ':'] delimchars* )?
  (* Old brackets, no new brackets starting with "[|" or "[:" *)
  | '[' ['|' ':']?
   (* Old "[<","{<" and new ones *)
  | ['[' ] delimchars* '<'
  | '[' '='
  | '[' '>' 
let right_delimitor =
  (* At least a safe_delimchars *)
  (delimchars|right_delims)* safe_delimchars (delimchars|right_delims)* right_delims
   | (delimchars* ['|' ':'])? ')'
   | ['|' ':']? ']'
   | '>' delimchars* [']' ]
let ocaml_escaped_char =
  '\\' (['\\' '"' 'n' 't' 'b' 'r' ' ' '\''] | ['0'-'9'] ['0'-'9'] ['0'-'9'] |'x' hexa_char hexa_char)
let ocaml_char =
  ( [! '\\' '\010' '\013'] | ocaml_escaped_char)
let ocaml_lid =
  lowercase identchar *
let ocaml_uid =
  uppercase identchar * 
|};;

let fprintf = Format.fprintf
let eprintf = Format.eprintf



(** put elements from stream to string with offset 0 and [max] elements *)  
let lexing_store s buff max =
   let  self n s =
     if n >= max then n
     else
       match Fstream.peek s with
       | Some x -> (Fstream.junk s; buff.[n] <- x; n + 1)
       | _ -> n in 
   self 0 s
    
type lex_error  =
  | Illegal_character of char
  | Illegal_escape    of string
  | Illegal_quotation of string
  | Illegal_antiquote 
  | Unterminated_comment
  | Unterminated_string
  | Unterminated_quotation
  | Unterminated_antiquot
  | Comment_start
  | Comment_not_end

exception Lexing_error  of lex_error

let print_lex_error ppf e =
  match e with
  | Illegal_antiquote ->
      fprintf ppf "Illegal_antiquote"
  | Illegal_character c ->
      fprintf ppf "Illegal character (%s)" (Char.escaped c)
  | Illegal_quotation s ->
      fprintf ppf "Illegal quotation (%s)" (String.escaped s)
  | Illegal_escape s ->
      fprintf ppf "Illegal backslash escape in string or character (%s)" s
  | Unterminated_comment ->
      fprintf ppf "Comment not terminated"
  | Unterminated_string ->
      fprintf ppf "String literal not terminated"
  | Unterminated_quotation ->
      fprintf ppf "Quotation not terminated"
  | Unterminated_antiquot ->
      fprintf ppf "Antiquotation not terminated"
  | Comment_start ->
      fprintf ppf "this is the start of a comment"
  | Comment_not_end ->
      fprintf ppf "this is not the end of a comment"
            
let lex_error_to_string = Formatf.to_string print_lex_error

    
let debug = ref false

let opt_char_len  = function
  | Some _ -> 1
  | None -> 0

let print_opt_char fmt = function
  | Some c ->fprintf fmt "Some %c" c
  | None -> fprintf fmt "None"
        
module CStack=struct   
  include Stack
  let push v stk= begin 
    if!debug then Format.eprintf "Push %a@." print_opt_char v else ();
    push v stk
  end 
  let pop stk = begin
    if !debug then Format.eprintf "Pop %a@." print_opt_char (top stk);
    pop stk
  end 
end
let opt_char : char option Stack.t = Stack.create ()
let turn_on_quotation_debug () = debug:=true
let turn_off_quotation_debug () = debug:=false
let clear_stack () = Stack.clear opt_char 
let show_stack () = begin
  eprintf "stack expand to check the error message@.";
  Stack.iter (Format.eprintf "%a@." print_opt_char ) opt_char 
end

type kind =
  | Comment
  | String
  | Quote
  | Brace
  | Anti 


type context = {
    mutable loc : (FLoc.position * kind)  list;
    buffer : Buffer.t;
  }

   
let new_cxt () = {
  loc = [];
  buffer = Buffer.create 256;
}      





(*************************************)
(*    local operators                *)    
(*************************************)        
let (++) = Buffer.add_string       
let (+>) = Buffer.add_char
(** get the location of current the lexeme *)
let (!!)  = Location_util.from_lexbuf
let (--) = Location_util.(--)

    
(** To buffer string literals, quotations and antiquotations
    store the current lexeme *)
let store c lexbuf =
  c.buffer ++ Lexing.lexeme lexbuf

let with_store c lexbuf f =  
  begin
    store c  lexbuf;
    f c lexbuf
  end

(** get the contents and reset *)    
let buff_contents c =
  let contents = Buffer.contents c.buffer in
  begin
    Buffer.reset c.buffer;
    contents
  end
    




(** [unsafe] shift the lexing buffer, usually shift back *)    
let move_curr_p shift  (lexbuf:Lexing.lexbuf)  =
  lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos + shift

      

let push_loc_cont  kind c lexbuf lexer =
  begin
    c.loc <-  (Lexing.lexeme_start_p lexbuf, kind) :: c.loc;
    lexer c lexbuf
  end
(** unsafe, [@raise Failure] *)
let pop_loc c =
    c.loc <- List.tl c.loc
let null_loc c =
  c.loc = []
    


(** Update the current location with file name and line number.
   change [pos_fname] [pos_lnum] and [pos_bol],
   default behavior is adding a newline
    [retract] is only used for ocaml convention
    for example

    {[
    '
    '
    bol would require retract one chars  when parsing it as a whole
    ]}
 *)
let update_loc ?file ?(absolute=false) ?(retract=0) ?(line=1)   (lexbuf:Lexing.lexbuf)  =
  let pos = lexbuf.lex_curr_p in
  let new_file = match file with
  | None -> pos.pos_fname
  | Some s -> s in
  lexbuf.lex_curr_p <-
    { pos with
      pos_fname = new_file;
      pos_lnum = if absolute then line else pos.pos_lnum + line;
      pos_bol = pos.pos_cnum - retract;}
      
let err (error:lex_error) (loc:FLoc.t) =
  raise (FLoc.Exc_located(loc, Lexing_error error))

let warn error (loc:FLoc.t) =
  Fan_warnings.emitf loc.loc_start "Warning: %s"  @@ lex_error_to_string error


(** return unit. All the comments are stored in the buffer
    Note that comment is isolate to quotation and antiquotation.
    The function itself already simulate its stack, and it will not distrub the stack
    since when comment token is lexed. The stack is returned back to normal
 *)
let rec lex_comment c = {:lexer|
|"(*"  ->
    begin
      store c lexbuf ;
      push_loc_cont Comment c lexbuf lex_comment;
      lex_comment c lexbuf
    end
| "*)"  ->
    begin
      store c lexbuf;
      pop_loc c ;
    end
| newline ->
    begin
      update_loc  lexbuf ;
      with_store  c lexbuf lex_comment;
    end
| eof ->
    err Unterminated_comment  @@ (* FIXME *)
    Location_util.of_positions (List.hd c.loc) lexbuf.lex_curr_p
| _ ->  with_store c lexbuf lex_comment  
|}


(** called by another lexer
    | '"' -> ( with_curr_loc  c string; let s = buff_contents c in `Str s )
    c.loc keeps the start position of "ghosgho"
    c.buffer keeps the lexed result
 *)    
let rec lex_string c = {:lexer|
| '"' ->  pop_loc c
| '\\' newline ([' ' '\t'] * as space) ->
    (* Follow the ocaml convention, these characters does not take positions *)
    begin
      update_loc  lexbuf  ~retract:(String.length space);
      lex_string c lexbuf
    end
| ocaml_escaped_char -> with_store  c lexbuf lex_string
| '\\' (_ as x) ->
    begin
      warn
        (Illegal_escape (String.make 1 x)) @@ Location_util.from_lexbuf lexbuf;
      with_store c lexbuf lex_string
    end
| newline ->
    begin
      update_loc  lexbuf;
      with_store  c lexbuf lex_string
    end
| eof ->  err Unterminated_string @@
    Location_util.of_positions (List.hd c.loc) lexbuf.lex_curr_p
| _ ->  with_store  c lexbuf lex_string
|}



(** Then prefix is something like "$(" *)
let rec  lex_antiquot c  = {:lexer|
| ')' ->
    begin
      pop_loc c;
      store c lexbuf
    end
| '(' ->
    begin 
      store c lexbuf;
      push_loc_cont Anti c lexbuf lex_antiquot;
      lex_antiquot c  lexbuf;
    end
| quotation_prefix -> (* $(lid:%{)})*)
    begin 
      store c lexbuf;
      push_loc_cont Quote  c lexbuf lex_quotation;
      lex_antiquot c lexbuf
    end
| newline   ->
    begin
      update_loc  lexbuf;
      with_store c lexbuf lex_antiquot 
    end
| "\"" -> (* $(")")*)
    begin
      store c lexbuf;
      push_loc_cont String c lexbuf lex_string;
      c.buffer +> '"';
      lex_antiquot  c lexbuf
    end
| eof  ->
    err Unterminated_antiquot
    @@  Location_util.of_positions (List.hd c.loc) lexbuf.lex_curr_p
| "'" ocaml_char "'" -> with_store  c lexbuf lex_antiquot (* $( ')' ) *)
| _  ->  with_store c lexbuf lex_antiquot 
|}

(** [lex_quotation] may be called by other lexer recursively. You can not assume that
    it's always called in the outest level
 *)    
and lex_quotation c = {:lexer|

| quotation_prefix 
  ->
    begin
      store c lexbuf ;
      push_loc_cont Quote c lexbuf lex_quotation;
      lex_quotation c lexbuf
    end
| "}@{" ->
    
    Buffer.add_char
| "}" ->
    begin
      store c lexbuf;
      pop_loc c ;
    end
| "{" ->
    begin
      store c lexbuf;
      push_loc_cont c lexbuf lex_quotation ;
      lex_quotation c lexbuf;
    end
    
| "}" ->
    if not (Stack.is_empty opt_char) then
      let top = Stack.top opt_char in
      if p <> top then
        with_store  c lexbuf lex_quotation (*move on*)
      else begin
        ignore (Stack.pop opt_char);
        store c lexbuf
      end
    else
      with_store  c lexbuf lex_quotation
| "(*" ->
    begin
      push_loc_cont c lexbuf lex_comment;
      lex_quotation c lexbuf
    end

| newline ->
    begin
      update_loc  lexbuf ;
      with_store c lexbuf lex_quotation 
    end          
| "\"" -> (* treat string specially, like %{ "{|"} should be accepted *)
    begin
      store c lexbuf;
      push_loc_cont c lexbuf lex_string;
      Buffer.add_char c.buffer '"';
      lex_quotation c lexbuf
    end
| eof ->
    begin
      show_stack ();
      err Unterminated_quotation @@
      Location_util.of_positions (List.hd c.loc) lexbuf.lex_curr_p
    end
| "'" ocaml_char "'" -> (* treat  char specially, otherwise '"' would not be parsed  *)
    with_store c lexbuf lex_quotation 
| _ -> with_store c lexbuf  lex_quotation |}


let rec lex_simple_quotation c =   {:lexer|
| "}" ->
    begin
      store c lexbuf;
      pop_loc c ;
    end
| "{" ->
    begin
      store c lexbuf;
      push_loc_cont c lexbuf lex_simple_quotation ;
      lex_simple_quotation c lexbuf;
    end
| "(*" ->
    begin
      push_loc_cont c lexbuf lex_comment;
      lex_simple_quotation c lexbuf
    end
| newline ->
    begin
      update_loc lexbuf;
      with_store c lexbuf lex_simple_quotation  ;
    end
| "\"" ->
    begin
      store c lexbuf;
      push_loc_cont c lexbuf lex_string;
      Buffer.add_char c.buffer '"';
      lex_simple_quotation  c lexbuf
    end
| eof -> err Unterminated_quotation @@ List.hd c.loc -- lexbuf.lex_curr_p
| "'" ocaml_char "'" -> (* treat  char specially, otherwise '"' would not be parsed  *)
    with_store c lexbuf  lex_simple_quotation 

| _  -> with_store  c lexbuf lex_simple_quotation 
|}
    


let _ =
  Printexc.register_printer @@ function
    | Lexing_error e -> Some (lex_error_to_string e)
    | _ -> None   

(* local variables: *)
(* compile-command: "cd ../main_annot && pmake lexing_util2.cmo" *)
(* end: *)