open Astfn
let sem a b = `Sem (a, b)
let com a b = `Com (a, b)
let app a b = `App (a, b)
let apply a b = `Apply (a, b)
let sta a b = `Sta (a, b)
let bar a b = `Bar (a, b)
let anda a b = `And (a, b)
let dot a b = `Dot (a, b)
let par x = `Par x
let seq a = `Seq a
let arrow a b = `Arrow (a, b)
let typing a b = `Constraint (a, b)
let bar_of_list xs = Ast_basic.of_listr bar xs
let and_of_list xs = Ast_basic.of_listr anda xs
let sem_of_list xs = Ast_basic.of_listr sem xs
let com_of_list xs = Ast_basic.of_listr com xs
let sta_of_list xs = Ast_basic.of_listr sta xs
let dot_of_list xs = Ast_basic.of_listr dot xs
let appl_of_list xs = Ast_basic.of_listl app xs
let seq_sem ls = seq (sem_of_list ls)
let binds bs (e : exp) =
  match bs with
  | [] -> e
  | _ ->
      let binds = and_of_list bs in
      (`LetIn (`Negative, (binds :>Astfn.bind), (e :>Astfn.exp)) :>Astfn.exp)
let lid (n : string) = `Lid n
let uid (n : string) = `Uid n
let unit: ep = `Unit
let tuple_com_unit =
  function | [] -> unit | p::[] -> p | y -> `Par (com_of_list y)
let tuple_com y =
  match y with
  | [] -> invalid_arg ("Astn_util" ^ ("." ^ "tuple_com"))
  | x::[] -> x
  | _ -> `Par (com_of_list y)
let tuple_sta y =
  match y with
  | [] -> invalid_arg ("Astn_util" ^ ("." ^ "tuple_sta"))
  | x::[] -> x
  | _ -> `Par (sta_of_list y)
let (+>) f (names : string list) = appl_of_list (f :: (List.map lid names))
let of_str (s : string) =
  (let len = String.length s in
   if len = 0
   then invalid_arg ("Astn_util" ^ ("." ^ "of_str"))
   else
     (match s.[0] with
      | '`' -> (`Vrn (String.sub s 1 (len - 1)) :>Astfn.ep)
      | x when (Charf.is_uppercase x) || (s = "::") -> (`Uid s :>Astfn.ep)
      | _ -> (`Lid s :>Astfn.ep)) : ep )
