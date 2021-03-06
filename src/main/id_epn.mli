
(** Ast Utilities for [Astfn.ep] *)
  
open Astfn

val tuple_of_number : ep -> int -> ep


val of_vstr_number : string -> int -> ep


(** used by [Derive.exp_of_ctyp] to generate patterns *)
val gen_tuple_n :
  ?cons_transform:(string -> string) -> arity:int -> string -> int -> ep




val mk_tuple : arity:int -> number:int -> ep

