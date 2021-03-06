
%create{register}  ;;
(* todo more error checking *)
let compile _loc pairs =
  let tbl = Hashtbl.create 30 in
  let () =
    List.iter (fun ((k,kloc),(v,vloc)) ->
      Hashtbl.add tbl k (kloc,v,vloc)) pairs in
  let
    try (_,entry,loc) = Hashtbl.find tbl "entry" in
    let e = %exp@loc{$lid:entry} in
    let
      try (_,name,loc) = Hashtbl.find tbl "name" in
      let n = %exp@loc{$str:name} in
      let 
        try (_,pos,loc) = Hashtblf.find tbl "position" in
         
         let p = %ident'@loc{$lid{"of_" ^ pos} } in
         let lexer = Hashtblf.find_opt tbl "lexer" in
         begin
           match lexer with
           | None -> %exp{
               Ast_quotation.$p
                 ~name:{domain = Ns.lang; name = $n }
                 ~entry:$e
                 ~lexer:Lex_fan.from_stream (* warning may be needed *)
                 ()
             }
           | Some (_,l,loc) ->
               let l = %exp@loc{~lexer:$lid:l} in
               %exp{
               Ast_quotation.$p
                 ~name:{domain = Ns.lang; name = $n }
                 ~entry:$e
                 $l                  
                 ()
             }
         end
        with
          Not_found ->
            Locf.failf _loc "`position' attribute is required"
      with Not_found ->
        Locf.failf _loc "`name attribute is required" 
  with Not_found
    ->  Locf.failf _loc "`entry' attribute is required" 
;;


let  rec token = %lex_fan{
  | @whitespace %{token lexbuf}
  | @ocaml_lid
  | @kwd_symbol(":" | ";" )
  | @ocaml_comment %{token lexbuf}
  | @ocaml_eof
  | @default};;
let make_register register compile =     
  %extend{
  register:
  [L1 pair SEP ";" as pairs %{ compile _loc pairs }]
  (* FIXME here ? ";" does not fix the trailing problem *)    
  pair@Local:
  [ Lid@xloc x; ":"; Lid@yloc y %{((x,xloc),(y,yloc))} ]
  };;

let from_stream = Lexing_util.adapt_to_stream token ;;

let () =
  begin
    make_register register compile;
    %register{
    position: exp;
    name:register;
    entry:register;
    lexer:from_stream
  }
  end;;

(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/lang_register.cmo" *)
(* end: *)
