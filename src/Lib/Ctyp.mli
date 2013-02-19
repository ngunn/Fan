open Ast 

val to_var_list : ctyp -> string list



val name_tags : ctyp -> string list

val to_generalized : ctyp -> ctyp list * ctyp


val arrow : ctyp -> ctyp -> ctyp
val ( |-> ) : ctyp -> ctyp -> ctyp
val arrow_of_list : ctyp list -> ctyp
val app_arrow : ctyp list -> ctyp -> ctyp
val ( <+ ) : string list -> ctyp -> ctyp
val ( +> ) : ctyp list -> ctyp -> ctyp
val name_length_of_tydcl : ctyp -> string * int
val gen_quantifiers : arity:int -> int -> ctyp
val of_id_len : off:int -> ident * int -> ctyp
val of_name_len : off:int -> string * int -> ctyp
val ty_name_of_tydcl : ctyp -> ctyp
val gen_ty_of_tydcl : off:int -> ctyp -> ctyp
val list_of_record : name_ctyp -> FSig.col list
val gen_tuple_n : ctyp -> int -> ctyp
val repeat_arrow_n : ctyp -> int -> ctyp
val mk_method_type :
  number:int ->
  prefix:string list -> ident * int -> FSig.destination -> (ctyp*ctyp)
val mk_method_type_of_name :
  number:int ->
  prefix:string list -> string * int -> FSig.destination -> (ctyp*ctyp)
      
(* val mk_dest_type: destination:FSig.destination -> ident * int -> ctyp  *)
        
val mk_obj : string -> string -> class_str_item -> str_item
val is_recursive : ctyp -> bool
val qualified_app_list : ctyp -> (ident * ctyp list) option
val is_abstract : ctyp -> bool
val abstract_list : ctyp -> int option
val eq : ctyp -> ctyp -> bool
val eq_list : ctyp list -> ctyp list -> bool
(* val mk_transform_type_eq : *)
(*   unit -> FanAst.map *)
  
val transform_module_types : FSig.module_types ->
  (string * ident * int) list * FSig.module_types

val reduce_data_ctors:
    ctyp ->
      'a -> compose:('e -> 'a  -> 'a) -> (string -> FanAst.ctyp list -> 'e) -> 'a    
(* @raise Invalid_argument *)        
val of_str_item: str_item -> ctyp 

val view_sum : ctyp -> FSig.branch list
val view_variant: ctyp -> FSig.vbranch list    
