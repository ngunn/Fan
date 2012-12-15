

open Transform;
open FSig;
open Lib;
let _loc = FanLoc.ghost ;
(**
   For var, in most cases we just add a prefix
   mf_, so we just fix it here

   For Objects, tctor_var, always (`Fun (fun x -> x))
   FIXME we may need a more flexible way to compose branches
 *)
let gen_str_item
    ?module_name
    ?(arity=1)
    ?(trail= {:expr| failwith "arity >= 2 in other branches" |} )
    ~id:(id:basic_id_transform)  ~names  
    (* you must specify when arity >=2 *)
    ~mk_tuple  ~mk_record mk_variant =
  let module M  = struct
    let mk_variant = mk_variant ;
    let mk_tuple = mk_tuple;
    let arity = arity;      
    let left_type_variable  = `Pre "mf_" ;
    let right_type_variable = `Pre "mf_";
    let left_type_id = id ;
    let right_type_id =  match module_name with
      [None ->   (id:>full_id_transform)
      |Some m ->
          `Last (fun s -> {:ident| $uid:m.$(lid:basic_transform id s) |} ) ] ;
    let trail (_,number)=
      if number > 1 then
        let patt = Patt.tuple_of_number {:patt| _ |} arity in 
        {:match_case| $pat:patt -> $trail |}
      else {:match_case| |} ;
    let names = names ;
    let mk_record = mk_record ;
  end in
  let module MM = Frame.Make(M) in
  MM.(str_item_of_module_types ?module_name normal_simple_expr_of_ctyp);
  
let gen_object
    ?module_name
    ?(arity=1)
    ?(trail= {:expr| failwith "arity >= 2 in other branches" |} )
    ~kind
    ~base
    ~class_name = 
  let make ~names ~mk_tuple  ~mk_record  mk_variant = 
    let module M  = struct
      let mk_variant = mk_variant ;
      let mk_tuple = mk_tuple;
      let arity = arity;
      let left_type_variable  = `Pre "mf_";
      let right_type_variable =
        `Exp (fun
          [v -> let v = basic_transform left_type_variable v
          in  {:expr| $lid:v self |} ]) ;
     let left_type_id  = `Pre "";
     let right_type_id  =
       `Obj (basic_transform left_type_id) ;
     let trail (_,number)=
       if number > 1 then
         let patt = Patt.tuple_of_number {:patt| _ |} arity in 
         {:match_case| $pat:patt -> $trail |}
       else {:match_case| |} ;
     let names = names ;
     let mk_record = mk_record;
   end in
  let module MM = Frame.Make(M) in
  MM.(obj_of_module_types
        ?module_name
        base
        class_name
        obj_simple_expr_of_ctyp
        kind) in
  make;



















