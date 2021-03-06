open Astf
open Util

type key = string

let inject_exp_tbl: (key,exp) Hashtbl.t = Hashtbl.create 40

let inject_stru_tbl: (key,stru) Hashtbl.t = Hashtbl.create 40
    
let inject_clfield_tbl: (key,clfield)Hashtbl.t = Hashtbl.create 40

let register_inject_exp (k,f)=
  Hashtbl.replace inject_exp_tbl k f
    
let register_inject_stru (k,f)=
  Hashtbl.replace inject_stru_tbl k f
    
let register_inject_clfield (k,f) =
  Hashtbl.replace inject_clfield_tbl k f
;;


%create{inject_exp inject_stru inject_clfield};;
  
%extend{
  inject_exp:
  [ Lid x %{
   try Hashtbl.find inject_exp_tbl x 
   with Not_found -> failwithf "inject.exp %s not found" x } ]

  inject_stru:
  [Lid x %{
   try Hashtbl.find inject_stru_tbl x
   with Not_found -> failwithf "inject.exp %s not found" x }]

  inject_clfield:
  [Lid x %{
   try Hashtbl.find inject_clfield_tbl x
   with Not_found -> failwithf "inject.exp %s not found" x }]
};;

let open Ast_quotation in
let domain = Ns.inject in
let lexer = Lex_fan.from_stream in
begin
  of_exp ~name:{domain; name = "exp"} ~entry:inject_exp ~lexer  ();
  of_stru ~name:{domain; name =  "stru"} ~entry:inject_stru ~lexer ();
  of_clfield ~name:{domain; name =  "clfield"} ~entry:inject_clfield ~lexer ();  
end

(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/ast_inject.cmo" *)
(* end: *)
