%import{
Sigs_util:
  pp_print_mtyps
  pp_print_types
  ;
Format:
  eprintf
  ;
};;
open Util
open Ast_basic

(** A Hook To Astf Filters *)
(* type plugin_name = string  *)

let filters : (Sigs_util.plugin_name, Sigs_util.plugin) Hashtbl.t  = Hashtbl.create 30;;

let show_code =  ref false
let print_collect_mtyps = ref false
  
let register  ?filter ?position (name,transform) =
  if Hashtbl.mem filters name then
    eprintf "Warning:%s filter already exists!@." name
  else 
   Hashtbl.add filters name {transform; position;filter} 


let show_modules () =
  begin
    Hashtbl.iter
      (fun key _  ->
        Format.printf  "%s@ " key ) filters;
    print_newline()
  end
  
(* Get all definitions from mli file
  Entrance: sigi *)


let plugin_add plugin =
  let try v = Hashtbl.find filters plugin in 
    if not @@
      List.exists (fun (n,_) -> n=plugin) !State.current_filters
    then
      Ref.modify State.current_filters (fun x -> cons (plugin,v) x) 
    else
      eprintf "<Warning> plugin %s has already been loaded" plugin

  with Not_found -> begin
    show_modules ();
    failwithf "plugins %s not found " plugin ;
  end

    
let plugin_remove plugin =
    Ref.modify State.current_filters (fun x -> Listf.remove plugin x) 
  




class type traversal = object
  inherit Astf_map.map
  method get_cur_mtyps: Sigs_util.mtyps
  method get_cur_and_types: Sigs_util.and_types
  (* method in_and_types: *)
  method update_cur_and_types:
      (Sigs_util.and_types -> Sigs_util.and_types) -> unit
  method update_cur_mtyps:
      (Sigs_util.mtyps -> Sigs_util.mtyps) -> unit

end

      
let make_filter (s,code) =
  let f =  function
    | %stru{ $lid:s'} when s =s' ->
        Fill.stru _loc code
    | e -> e   in
  ("filter_"^s, (Astf_map.map_stru f )#stru)

let iterate_code sloc mtyps = 
  (fun (_, (x:Sigs_util.plugin)) acc ->
    let mtyps =
      match x.filter with
      |Some x -> Sigs_util.apply_filter x mtyps
      |None -> mtyps in
    let code = x.transform mtyps in 
    match (x.position,code) with
    |(Some x,Some code) ->
        let (name,f) = make_filter (x,code) in 
        (Ast_filters.register_stru_filter (name,f);
         Ast_filters.use_implem_filter name ;
         acc)
    |(None,Some code) ->
        let code = Fill.stru sloc code in
        (%stru@sloc{ $acc;; $code };)
    |(_,None) -> acc);;
 
let traversal () : traversal  = object (self)
  inherit Astf_map.map as super
  val mtyps_stack : Sigs_util.mtyps Stack.t  = Stack.create ()
  val mutable cur_and_types : Sigs_util.and_types= []
  val mutable and_group = false
  method get_cur_mtyps : Sigs_util.mtyps =
    Stack.top mtyps_stack
  method update_cur_mtyps f =
    Stack.(push (f (pop mtyps_stack)) mtyps_stack)
  method private in_module =  Stack.push [] mtyps_stack 
  method private out_module = ignore (Stack.pop mtyps_stack)
      
  method private in_and_types =  (and_group <- true; cur_and_types <- [])
  method private out_and_types = (and_group <- false; cur_and_types <- [])
  method private is_in_and_types = and_group
  method get_cur_and_types = cur_and_types
  method update_cur_and_types f = 
    cur_and_types <-  f cur_and_types

  (** entrance *)  
  method! mexp = with stru function
    | %mexp@sloc{ struct $u end }  ->
        (self#in_module ;
         (* extracted code *)
         let res = self#stru u in
         let mtyps = List.rev (self#get_cur_mtyps) in
         let () = if !print_collect_mtyps then
           eprintf "@[%a@]@." pp_print_mtyps mtyps in
         let result =
         List.fold_right 
             (iterate_code sloc mtyps)
             !State.current_filters 
             (if !State.keep then res else %@sloc{ let _ = () }) in
            (self#out_module ; %mexp@sloc{ struct $result end } ))

    | x -> super#mexp x
          
  method! stru  =   function
    | `Type(_loc ,`And _) (* %{ type $_ and $_ }  *)as x -> begin
      self#in_and_types;
      let _ = super#stru x in
      (self#update_cur_mtyps
          (fun lst -> Mutual (List.rev self#get_cur_and_types) :: lst );
       self#out_and_types;
       (if !State.keep then x else %stru{ let _ = () } (* FIXME *) ))
    end
    | `TypeWith(_loc,decl,_) ->
        self#stru (`Type(_loc,decl))

    | `Type (_loc,(`TyDcl (_,`Lid(_, name), _, _, _) as t) ) as x -> 
        let item =  Sigs_util.Single (name, Strip.decl t) in
        let () =
          if !print_collect_mtyps then eprintf "Came across @[%a@]@."
              pp_print_types  item in
        begin
          self#update_cur_mtyps (fun lst -> item :: lst);
          (* if !keep then x else %{ } *) (* always keep *)
          x 
        end
    | `Type(_loc, (`TyAbstr (_,`Lid (_,name),_,_) as t)) as x -> 
        let item = Sigs_util.Single (name, Strip.decl t) in 
        let () =
          if !print_collect_mtyps then eprintf "Came across @[%a@]@."
              pp_print_types  item in
        begin
          self#update_cur_mtyps (fun lst -> item :: lst);
          x
        end
    | (`Value _ |`ModuleType _ | `Include _ 
    | `External _ | `StExp _ | `Exception _ 
    | `Directive _  as x ) -> x (* always keep *)
    |  x ->  super#stru x  
  method! decl = function
    | `TyDcl (_, `Lid(_,name), _, _, _) as t -> 
      ((if self#is_in_and_types then
        self#update_cur_and_types (fun lst ->
          (name,Strip.decl t) :: lst ));
        t)
    | t -> super#decl t 
end


let genenrate_type_code _loc tdl (ns:Astf.strings) : Astf.stru = 
  let x : Astf.stru = `Type(_loc,tdl)  in
  let ns = list_of_app ns [ ] in
  let filters =
    List.map (function
      |`Str(sloc,n) ->
          let n = String.capitalize n in
          (match Hashtblf.find_opt filters n with
          | None -> Locf.failf sloc "%s not found" n
          | Some p -> (n,p))
      | `Ant _ -> Locf.raise _loc (Failure"antiquotation not expected here")
      | _ -> assert false ) ns in
  let code =
    Ref.protect2
      (State.current_filters, filters)
      (State.keep, false)
      (fun _  ->
        match (traversal ())#mexp (`Struct(_loc,x): Astf.mexp) with
        | (`Struct(_loc,s):Astf.mexp) -> s
        | _ -> assert false) in
  %stru{$x;; $code}


let () = begin
  Ast2pt.generate_type_code := genenrate_type_code
end

(* local variables: *)
(* compile-command: "cd .. && pmake main_annot/typehook.cmo" *)
(* end: *)
