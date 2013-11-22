(* source reference : lexer.mll from 4.02dev+trunk *)    

%regex{ (** FIXME remove duplication later see lexing_util.cmo *)
let not_star_symbolchar =
  [ '!' '%' '&' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '|' '~' '\\']
let symbolchar = '*'|not_star_symbolchar

};;

(** get the location of current the lexeme *)
let (!!)  = Lexing_util.from_lexbuf ;;

(** It could also import regex in the future
    {:import|
    Lexing_util:
    with_curr_loc
    update_loc ;
   Location_util:
    (--)
    from_lexbuf as  (!!)
    lex_antiquot : %{ a -> b -> c}  as xx ;
   Buffer:
    add_string -> (++)
    add_char -> (+>) ;
   |}  *)
let  rec token   = %lex_fan{
   | @whitespace %{ token lexbuf}
   | @ocaml_comment %{token lexbuf}
   | ocaml_lid as txt  %{
     let v = Hashtbl.hash txt in
     if  %hash_cmp{"mod"|"land"|"lor"|"lxor"} txt v  then
       `Inf{loc= !!lexbuf; txt ; level = 3}
     else if %hash_cmp{"lsl"|"lsr" | "asr"} txt v then
       `Inf{loc= !!lexbuf; txt ; level = 4}
     else 
       if %hash_cmp{"functor"|"private"|"sig"
            | "include"| "exception"| "inherit"
            | "and"| "when"| "then"| "initializer"
            | "in" | "downto"| "as"| "function"
            | "begin"| "class"| "do"|   "end"
            | "assert"| "external"| "virtual"| "to"
            | "try" | "struct"| "else"
            | "val" | "constraint"| "type"
            | "new" | "of"| "done"
            | "for" | "fun"| "method"
            | "mutable"| "lazy"| "with"
            | "if" | "while" | "rec"
            | "object" | "or"
            | "match" | "open"| "module"|"let"|"_"} txt v then
       `Key {loc= !!lexbuf;txt}
     else
        `Lid {loc= !!lexbuf;txt}}
   | @ocaml_uid
   | @ocaml_num_literal
   | @ocaml_float_literal       (** FIXME safety check *)
   | @ocaml_string
   | @ocaml_char
   | "~" (ocaml_lid as txt) ':' %{`Label {loc= !! lexbuf;txt}}
   | "?" (ocaml_lid as txt) ':' %{`Optlabel {loc= !!lexbuf;txt}}
   | '(' (not_star_symbolchar symbolchar* as txt) ocaml_blank* ')' %{
     `Lid { loc = !! lexbuf ; txt}}
   | '(' ocaml_blank+ (symbolchar+ as txt) ocaml_blank* ')' %{
     `Lid {loc = !!lexbuf;txt}}
   | '(' ocaml_blank* ("or" | "mod"|"land"|"lor" |"lxor"
     |"lsl"|"lsr"|"asr" as txt) ocaml_blank* ')' %{
     `Lid {loc = !! lexbuf;txt}}
   | @kwd_symbol( "&&" | "#"  | "`"  | "'"  | ","  | "."  | ".." | ":"  | "::"|"+"|"-"
   | ":=" | ":>" | ";"  | ";;" | "{"|"}" |"-."
   | "{<" |">}"
   | "("  | "[|" | "["  | "[<" | "[=" | "[>"
   | ")" | "|]" | "]" | ">]"
   | "||" | "<" | "->" |  "=" | "|" | "==" | "*" | "<-"
   | "&"  | ">" 
   | "!"  | "~" |  "?"   |"??"  (* FIXME*))
       
   | '!' symbolchar+ as txt %{ `Pre{loc= !!lexbuf; txt}}
   | ['~' '?'] symbolchar+ as txt  %{`Pre{loc = !!lexbuf; txt }}
   | "**" symbolchar* as txt %{ `Inf{loc = !!lexbuf; txt ; level = 4}}
   | ['*' '/' '%'] symbolchar* as txt  %{`Inf{loc = !!lexbuf; txt ; level = 3}}
   | ['+' '-'] symbolchar + as txt %{`Inf{loc = !!lexbuf; txt ; level = 2}}
   | ['@' '^'] symbolchar * as txt %{`Inf{loc = !!lexbuf; txt; level = 1}  }
   | ['=' '<' '>' '|' '&'] symbolchar *  as txt %{`Inf{loc = !!lexbuf; txt ; level = 0}}
           
   | "*)" %{
       begin
         Lexing_util.warn Comment_not_end (!! lexbuf) ;
         Lexing_util.move_curr_p (-1) lexbuf;
         `Inf{loc = !!lexbuf; txt ="*";level = 3}
       end}
   | @ocaml_double_quotation
   | @line_directive %{token lexbuf}       
   | @ocaml_ant
   | @ocaml_eof
   | @default}

    
let from_lexbuf  = Lexing_util.adapt_to_buf token
let from_stream = Lexing_util.adapt_to_stream token
let from_string = Lexing_util.adapt_to_string token     
(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/lex_fan.cmo" *)
(* end: *)

