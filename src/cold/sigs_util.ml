open Astn_util
open Astfn
let pp_print_decl = Astfn_print.pp_print_decl
type named_type = (string* decl) 
and and_types = named_type list 
and types =  
  | Mutual of and_types
  | Single of named_type 
and mtyps = types list 
let rec pp_print_named_type: Format.formatter -> named_type -> unit =
  fun fmt  eta__019_  ->
    (fun fmt  (_a0,_a1)  ->
       Format.fprintf fmt "@[<1>(%a,@,%a)@]"
         (fun fmt  -> Format.fprintf fmt "%S") _a0 pp_print_decl _a1) fmt
      eta__019_
and pp_print_and_types: Format.formatter -> and_types -> unit =
  fun fmt  eta__018_  ->
    (fun mf_a  fmt  lst  ->
       Format.fprintf fmt "@[<1>[%a]@]"
         (fun fmt  -> List.iter (fun x  -> Format.fprintf fmt "%a@ " mf_a x))
         lst) pp_print_named_type fmt eta__018_
and pp_print_types: Format.formatter -> types -> unit =
  fun fmt  ->
    function
    | Mutual _a0 ->
        Format.fprintf fmt "@[<1>(Mutual@ %a)@]" pp_print_and_types _a0
    | Single _a0 ->
        Format.fprintf fmt "@[<1>(Single@ %a)@]" pp_print_named_type _a0
and pp_print_mtyps: Format.formatter -> mtyps -> unit =
  fun fmt  eta__017_  ->
    (fun mf_a  fmt  lst  ->
       Format.fprintf fmt "@[<1>[%a]@]"
         (fun fmt  -> List.iter (fun x  -> Format.fprintf fmt "%a@ " mf_a x))
         lst) pp_print_types fmt eta__017_
type plugin_name = string 
type plugin = 
  {
  transform: mtyps -> stru option;
  position: string option;
  filter: (string -> bool) option} 
let apply_filter f (m : mtyps) =
  (let f =
     function
     | Single (s,_) as x -> if f s then Some x else None
     | Mutual ls ->
         let x =
           Listf.filter_map
             (fun ((s,_) as x)  -> if f s then Some x else None) ls in
         (match x with
          | [] -> None
          | x::[] -> Some (Single x)
          | y -> Some (Mutual y)) in
   Listf.filter_map f m : mtyps )
let stru_from_mtyps ~f:(aux : named_type -> decl)  (x : mtyps) =
  (match x with
   | [] -> None
   | _ ->
       let xs: stru list =
         List.map
           (function
            | Mutual tys ->
                let v = and_of_list (List.map aux tys) in
                (`Type (v :>Astfn.decl) :>Astfn.stru)
            | Single ty ->
                let v = aux ty in (`Type (v :>Astfn.decl) :>Astfn.stru)) x in
       Some (sem_of_list xs) : stru option )
let stru_from_ty ~f:(f : string -> stru)  (x : mtyps) =
  (let tys: string list =
     Listf.concat_map
       (function
        | Mutual tys -> List.map (fun ((x,_) : named_type)  -> x) tys
        | Single (x,_) -> [x]) x in
   sem_of_list (List.map f tys) : stru )
let mk_transform_type_eq () =
  object (self : 'this_type__016_)
    val transformers = Hashtbl.create 50
    inherit  Astfn_map.map as super
    method! stru =
      function
      | (`Type `TyDcl (_name,vars,ctyp,_) : Astfn.stru) as x ->
          let r =
            match ctyp with
            | `TyEq (_,t) -> Ctyp.qualified_app_list t
            | _ -> None in
          (match r with
           | Some (i,lst) ->
               let vars =
                 match vars with
                 | `None -> []
                 | `Some x -> Ast_basic.N.list_of_com x [] in
               if not ((vars : decl_params list  :>ctyp list) = lst)
               then super#stru x
               else
                 (let src = i and dest = Idn_util.to_string i in
                  Hashtbl.replace transformers dest (src, (List.length lst));
                  (`StExp `Unit :>Astfn.stru))
           | None  -> super#stru x)
      | x -> super#stru x
    method! ctyp x =
      match Ctyp.qualified_app_list x with
      | Some (i,lst) ->
          let lst = List.map (fun ctyp  -> self#ctyp ctyp) lst in
          let src = i and dest = Idn_util.to_string i in
          (Hashtbl.replace transformers dest (src, (List.length lst));
           appl_of_list ((`Lid dest :>Astfn.ctyp) :: lst))
      | None  -> super#ctyp x
    method type_transformers =
      Hashtbl.fold (fun dest  (src,len)  acc  -> (dest, src, len) :: acc)
        transformers []
  end
let transform_mtyps (lst : mtyps) =
  let obj = mk_transform_type_eq () in
  let item1 =
    List.map
      (function
       | Mutual ls ->
           Mutual (List.map (fun (s,ty)  -> (s, (obj#decl ty))) ls)
       | Single (s,ty) -> Single (s, (obj#decl ty))) lst in
  let new_types = obj#type_transformers in (new_types, item1)
