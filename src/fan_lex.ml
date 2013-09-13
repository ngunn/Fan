{:regexp|

let newline = ('\010' | '\013' | "\013\010")
let blank = [' ' '\009' '\012']
let lowercase = ['a'-'z' '\223'-'\246' '\248'-'\255' '_']
let uppercase = ['A'-'Z' '\192'-'\214' '\216'-'\222']
let identchar = ['A'-'Z' 'a'-'z' '_' '\192'-'\214' '\216'-'\246' '\248'-'\255' '\'' '0'-'9']
let ident = (lowercase|uppercase) identchar*
    
let quotation_name = '.' ? (uppercase  identchar* '.') *
    (lowercase (identchar | '-') * )
let locname = ident
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

let ocaml_char =
  ( [! '\\' '\010' '\013'] | '\\'
    (['\\' '"' 'n' 't' 'b' 'r' ' ' '\'']
     | ['0'-'9'] ['0'-'9'] ['0'-'9'] |'x' hexa_char hexa_char))       
|};;


open LibUtil  
open Format  
open Lexing
type lex_error  =
  | Illegal_character of char
  | Illegal_escape    of string
  | Illegal_quotation of string
  | Illegal_antiquote 
  | Unterminated_comment
  | Unterminated_string
  | Unterminated_quotation
  | Unterminated_antiquot
  | Unterminated_string_in_comment
  | Unterminated_string_in_quotation
  | Unterminated_string_in_antiquot
  | Comment_start
  | Comment_not_end
  | Literal_overflow of string

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
  | Unterminated_string_in_comment ->
      fprintf ppf "This comment contains an unterminated string literal"
  | Unterminated_string_in_quotation ->
      fprintf ppf "This quotation contains an unterminated string literal"
  | Unterminated_string_in_antiquot ->
      fprintf ppf "This antiquotaion contains an unterminated string literal"
  | Unterminated_quotation ->
      fprintf ppf "Quotation not terminated"
  | Unterminated_antiquot ->
      fprintf ppf "Antiquotation not terminated"
  | Literal_overflow ty ->
      fprintf ppf "Integer literal exceeds the range of representable integers of type %s" ty
  | Comment_start ->
      fprintf ppf "this is the start of a comment"
  | Comment_not_end ->
      fprintf ppf "this is not the end of a comment"

            
let lex_error_to_string = to_string_of_printer print_lex_error

let _ =
  Printexc.register_printer @@ function
    | Lexing_error e -> Some (lex_error_to_string e)
    | _ -> None     


let debug = ref false

let opt_char_len  = function
  | Some _ -> 1
  | None -> 0

let print_opt_char fmt = function
  | Some c ->fprintf fmt "Some %c" c
  | None -> fprintf fmt "None"
        
module Stack=struct   
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



    
type context =
    { loc        :  FLoc.position ;
     (*
      only record the start position when enter into a quotation or antiquotation
       everytime token is used, the loc is updated to be [lexeme_start_p]
      *)
      antiquots  : bool     ;
      lexbuf     : lexbuf   ;
      buffer     : Buffer.t }

let (++) = Buffer.add_string       
(* To buffer string literals, quotations and antiquotations *)
let store c =
  c.buffer ++ Lexing.lexeme c.lexbuf

let store_parse f c =  
  begin
    store c ;
    f c c.lexbuf
  end
                                  
let buff_contents c =
  let contents = Buffer.contents c.buffer in
  begin
    Buffer.reset c.buffer;
    contents
  end
    




(** [unsafe] shift the lexing buffer, usually shift back *)    
let move_curr_p shift c =
  c.lexbuf.lex_curr_pos <- c.lexbuf.lex_curr_pos + shift

      
(** create a new context with  the location of the context for the lexer
   the old context was untouched  *)      
let with_curr_loc lexer c =
  lexer {c with loc = Lexing.lexeme_start_p c.lexbuf } c.lexbuf
    

(** when you return a token make sure the token's location is correct *)
let mk_quotation quotation c ~name ~loc ~shift ~retract =
  let old = c.lexbuf.lex_start_p in
  let s =
    begin
      with_curr_loc quotation c;
      c.lexbuf.lex_start_p <- old;
      buff_contents c
    end in
  let content = String.sub s 0 (String.length s - retract) in
  `Quot {FToken.name;loc;shift;content}
    


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
let update_loc ?file ?(absolute=false) ?(retract=0) ?(line=1)  c  =
  let lexbuf = c.lexbuf in
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
  Fan_warnings.emitf loc.loc_start "Warning: %s"   (lex_error_to_string error)



let rec comment c = {:lexer|
  |"(*"  ->
      begin
        store c;
        with_curr_loc comment c;
        (* to give better error message, put the current location here *)
        comment c c.lexbuf
      end
  | "*)"  ->  store c (* finished *)

  | newline ->
      begin
        update_loc c ;
        store_parse comment c
      end
  | eof ->  err Unterminated_comment  @@ Location_util.of_positions c.loc c.lexbuf.lex_curr_p
  | _ ->  store_parse comment c 
|}


(** called by another lexer
      | '"' -> ( with_curr_loc string c; let s = buff_contents c in `Str s )
    c.loc keeps the start position of "ghosgho"
    c.buffer keeps the lexed result 
 *)    
let rec string c = {:lexer|
  | '"' ->    c.lexbuf.lex_start_p <-  c.loc (* finished *)
  | '\\' newline ([' ' '\t'] * as space) ->
      begin
        update_loc c  ~retract:(String.length space);
        store_parse string c
      end
  | '\\' ['\\' '"' 'n' 't' 'b' 'r' ' ' '\''] -> store_parse string c 
  | '\\' ['0'-'9'] ['0'-'9'] ['0'-'9'] ->  store_parse string c 
  | '\\' 'x' hexa_char hexa_char ->  store_parse string c 
  | '\\' (_ as x) ->
      (warn
         (Illegal_escape (String.make 1 x))
         (Location_util.from_lexbuf lexbuf);
        store_parse string c)
  | newline ->
      begin
        update_loc c ;
        store_parse string c
      end
  | eof ->  err Unterminated_string @@  Location_util.of_positions c.loc c.lexbuf.lex_curr_p
  | _ ->  store_parse string c 
|}



(* depth makes sure the parentheses are balanced *)
let rec  antiquot name depth c  = {:lexer|
  | ')' ->
      if depth = 0 then (* only cares about FLoc.start_pos *)
        (c.lexbuf.lex_start_p <-  c.loc ; `Ant(name, buff_contents c))
      else store_parse (antiquot name (depth-1)) c
  | '('    ->  store_parse (antiquot name (depth+1)) c
        
  | eof  -> err Unterminated_antiquot @@  Location_util.of_positions c.loc c.lexbuf.lex_curr_p
  | newline   ->
      begin
        update_loc c ;
        store_parse (antiquot name depth) c
      end
  | '{' (':' ident)? ('@' locname)? '|' (extra_quot as p)? ->
      begin 
        Stack.push p opt_char ;
        store c ;
        with_curr_loc quotation c ;
        antiquot name depth c c.lexbuf
      end
  | "\"" ->
      begin
        store c ;
        with_curr_loc string c;
        Buffer.add_char c.buffer '"';
        antiquot name depth c c.lexbuf
      end

  | _  ->  store_parse (antiquot name depth) c
|}

and quotation c = {:lexer|
  | '{' (':' quotation_name)? ('@' locname)? '|' (extra_quot as p)?
      ->
        begin
          store c ;
          Stack.push p opt_char; (* take care the order matters*)
          with_curr_loc quotation c ;
          quotation c c.lexbuf
        end
  | (extra_quot as p)? "|}" ->
      if not (Stack.is_empty opt_char) then
        let top = Stack.top opt_char in
        if p <> top then
          store_parse quotation c (*move on*)
        else begin
          ignore (Stack.pop opt_char);
          store c
        end
      else
        store_parse quotation c
  | "\"" ->
      begin
        store c;
        with_curr_loc string c;
        Buffer.add_char c.buffer '"';
        quotation c c.lexbuf
      end
  | "'" ( [! '\\' '\010' '\013'] | '\\' (['\\' '"' 'n' 't' 'b' 'r' ' ' '\'']
          | ['0'-'9'] ['0'-'9'] ['0'-'9'] |'x' hexa_char hexa_char)  ) "'"
           -> store_parse quotation c 
  | eof ->
     begin
      show_stack ();
      err Unterminated_quotation @@  Location_util.of_positions c.loc c.lexbuf.lex_curr_p
     end
  | newline ->
      begin
        update_loc c ;
        store_parse quotation c
      end
  | _ -> store_parse quotation c
          
|}
    
let  token c = {:lexer|
  | newline -> (update_loc c; `NEWLINE)

  | "~" (lowercase identchar * as x) ':' ->  `LABEL x 

  | "?" (lowercase identchar * as x) ':' -> `OPTLABEL x 

  | lowercase identchar * as x ->  `Lid x 

  | uppercase identchar * as x ->  `Uid x 

  | int_literal  (('l'|'L'|'n' as s ) ?) as x ->
      (match s with
      | Some 'l' -> `Int32 x
      | Some 'L' -> `Int64 x
      | Some 'n' -> `Nativeint x
      | _ -> `Int x )
      (* FIXME - int_of_string ("-" ^ s) ??
         safety check
       *)
  | float_literal as f -> `Flo f       (** FIXME safety check *)

  | '"' -> ( with_curr_loc string c; let s = buff_contents c in `Str s )
  | "'" (newline as x) "'" ->
           ( update_loc c  ~retract:1; `Chr x )

  | "'" (ocaml_char as x ) "'"
      -> `Chr x 

  | "'\\" (_ as c) -> 
      err (Illegal_escape (String.make 1 c)) @@ Location_util.from_lexbuf lexbuf

  | '(' (not_star_symbolchar symbolchar* as op) blank* ')' -> `Eident op 
  | '(' blank+ (symbolchar+ as op) blank* ')' -> `Eident op

  | ( "#"  | "`"  | "'"  | ","  | "."  | ".." | ":"  | "::"
    | ":=" | ":>" | ";"  | ";;" | "_" | "{"|"}"
    | left_delimitor | right_delimitor | "{<" |">}"
    | ['~' '?' '!' '=' '<' '>' '|' '&' '@' '^' '+' '-' '*' '/' '%' '\\'] symbolchar * )
    as x  ->  `SYMBOL x 

  | blank + as x ->  `BLANKS x 
  (* comment *)      
  | "(*" ->
      (store c;
       (with_curr_loc comment c;  `COMMENT ( buff_contents c)))
  | "(*)" -> 
      ( warn Comment_start (Location_util.from_lexbuf lexbuf) ;
        comment c c.lexbuf; `COMMENT (buff_contents c))
  | "*)" ->
      ( warn Comment_not_end (Location_util.from_lexbuf lexbuf) ;
        move_curr_p (-1) c; `SYMBOL "*")

  (* quotation handling *)      
  | "{|" (extra_quot as p)?  ->
      (
       Stack.push p opt_char;
       let len = 2 + opt_char_len p in 
       mk_quotation
         quotation c ~name:(FToken.empty_name) ~loc:"" ~shift:len ~retract:len)
  | "{||}" -> 
           `Quot { FToken.name=FToken.empty_name; loc=""; shift=2; content="" }
  | "{@" (ident as loc) '|' (extra_quot as p)?  ->
      begin
        Stack.push p opt_char;
        mk_quotation quotation c ~name:(FToken.empty_name) ~loc
          ~shift:(2 + 1 + String.length loc + (opt_char_len p))
          ~retract:(2 + opt_char_len p)
      end
  | "{@" _  as c ->
      err (Illegal_quotation c ) @@ Location_util.from_lexbuf lexbuf
  | "{:" (quotation_name as name) '|' (extra_quot as p)? ->
      let len = String.length name in
      let name = FToken.name_of_string name in
      begin
        Stack.push p opt_char;
        mk_quotation quotation c
          ~name ~loc:""  ~shift:(2 + 1 + len + (opt_char_len p))
          ~retract:(2 + opt_char_len p)
      end

  | "{:" (quotation_name as name) '@' (locname as loc) '|' (extra_quot as p)? -> 
      let len = String.length name in 
      let name = FToken.name_of_string name in
      begin
        Stack.push p opt_char;
        mk_quotation quotation c ~name ~loc
          ~shift:(2 + 2 + String.length loc + len + opt_char_len p)
          ~retract:(2 + opt_char_len p)
      end
  | "{:" _ as c -> err (Illegal_quotation c) @@ Location_util.from_lexbuf lexbuf

  |"#{:" (quotation_name as name) '|'  (extra_quot as p)? ->
      let len = String.length name in
      let () = Stack.push p opt_char in
      let retract = opt_char_len p + 2 in  (*/|} *)
      let old = c.lexbuf.lex_start_p in
        let s =
          (with_curr_loc quotation c; c.lexbuf.lex_start_p<-old;buff_contents c;) in

        let contents = String.sub s 0 (String.length s - retract) in
        `DirQuotation(3+1 +len +(opt_char_len p), name,contents)
  | "#" [' ' '\t']* (['0'-'9']+ as num) [' ' '\t']*
      ("\"" ([! '\010' '\013' '"' ] * as name) "\"")?
      [! '\010' '\013'] * newline ->
        let inum = int_of_string num in begin 
          update_loc c ?file:name ~line:inum ~absolute:true ;
          `LINE_DIRECTIVE(inum, name)
        end
  (* Antiquotation handling *)        
  | '$' ->
      (*  $lid:ident $ident  $(lid:ghohgosho)  $(....)  $(....) *)
      (* FIXME should support more flexible syntax ${:str|x hgoshgo|} $"Aghioho" *)
      let  dollar c = {:lexer|
      (* FIXME *| does not work * | work *)
        | ('`'? (identchar* |['.' '!']+) as name) ':' (antifollowident as x) ->
            begin
              let move_start_p shift c =
                c.lexbuf.lex_start_p <- FLoc.move_pos shift c.lexbuf.lex_start_p in
              move_start_p (String.length name + 1) c;  `Ant(name,x)
            end
        | lident as x  ->   `Ant("",x) 
        | '(' ('`'? (identchar* |['.' '!']+) as name) ':' ->

            antiquot name 0
              {c with loc = FLoc.move_pos (3+String.length name) c.loc}
              c.lexbuf
        | '(' ->
            antiquot "" 0 {c with loc = FLoc.move_pos  2 c.loc} c.lexbuf 
        | _ as c ->
            err (Illegal_character c) (Location_util.from_lexbuf lexbuf) |} in        
      if  c.antiquots then  (* FIXME maybe always lex as antiquot?*)
        with_curr_loc dollar c
      else err Illegal_antiquote (Location_util.from_lexbuf lexbuf)
  | eof ->
      let pos = lexbuf.lex_curr_p in
      (lexbuf.lex_curr_p <-
        { pos with pos_bol  = pos.pos_bol  + 1 ;
          pos_cnum = pos.pos_cnum + 1 };
       `EOI)
  | _ as c ->  err (Illegal_character c) (Location_util.from_lexbuf lexbuf) 
|}

     
let from_lexbuf lb =
  (** lexing entry *)
  let c = {
    loc = Lexing.lexeme_start_p lb;
    antiquots = !FConfig.antiquotations;
    lexbuf = lb;
    buffer = Buffer.create 256
  } in
  let next _ =
    let tok =  token {c with loc = Lexing.lexeme_start_p c.lexbuf } c.lexbuf in
    let loc = Location_util.from_lexbuf c.lexbuf in
    Some ((tok, loc)) in (* this requires the [lexeme_start_p] to be correct ...  *)
  XStream.from next
