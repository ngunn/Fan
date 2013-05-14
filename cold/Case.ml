open LibUtil

open Ast

open AstLib

open Basic

let gen_tuple_abbrev ~arity  ~annot  ~destination  name e =
  let _loc = FanLoc.ghost in
  let args: pat list =
    List.init arity
      (fun i  ->
         (`Alias
            (_loc, (`ClassPath (_loc, name)), (`Lid (_loc, (x ~off:i 0)))) : 
         Ast.pat )) in
  let exps = List.init arity (fun i  -> (xid ~off:i 0 : Ast.exp )) in
  let e = appl_of_list (e :: exps) in
  let pat = args |> tuple_com in
  let open FSig in
    match destination with
    | Obj (Map ) ->
        (`Case (_loc, pat, (`Coercion (_loc, e, (name :>ctyp), annot))) : 
        Ast.case )
    | _ -> (`Case (_loc, pat, (`Subtype (_loc, e, annot))) : Ast.case )