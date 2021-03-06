%import{
Ast_gen:
  and_of_list
  seq_sem
  ;
};;

  
%create{save_quot};;
%extend{save_quot:
  [ L1 Lid as ls ; Quot x  %{
   let b =
     if x.name = Tokenf.empty_name then
       let expander loc _ s =
         Gramlib.parse_string_eoi ~loc Syntaxf.exp s in (* FIXME *)
       Tokenf.quot_expand expander x
     else Ast_quotation.expand x Dyn_tag.exp in
    let symbs = List.map (fun ({txt;_}:Tokenf.txt) -> %fresh{$txt}) ls in
    let res = %fresh{res} in
    let exc = %fresh{e} in
    let binds = and_of_list
        (List.map2 (fun x (y:Tokenf.txt) -> %bind{ $lid:x = ! $lid{y.txt} } ) symbs ls ) in
    let restore =
       seq_sem (List.map2 (fun  (x:Tokenf.txt) y -> %exp{ $lid{x.txt} := $lid:y }) ls symbs) in
    %exp{
    let $binds in
    try
      begin 
        let $lid:res = $b in
        let _ = $restore in 
        $lid:res    
      end
    with
    | $lid:exc ->
        begin
          $restore ;
          raise $lid:exc
        end} } ]};;
let lexer = Lex_fan.from_stream in
%register{
position:exp;
name: save;
entry: save_quot;
lexer:lexer
};;

(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/lang_save.cmo" *)
(* end: *)
