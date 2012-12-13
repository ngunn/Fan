
type 'a expand_fun = FanLoc.t -> string option -> string -> 'a

val add: string -> 'a DynAst.tag -> 'a expand_fun -> unit

val default: string ref

val default_tbl: (string, string) LibUtil.Hashtbl.t

val default_at_pos: string -> string -> unit

val parse_quotation_result:
    (FanLoc.t -> string -> 'a) ->
      FanLoc.t -> FanToken.quotation -> string -> string -> 'a

val translate: (string -> string) ref

val expand: FanLoc.t -> FanToken.quotation -> 'a DynAst.tag -> 'a

val dump_file: string option ref

val add_quotation:
   expr_filter:('a -> Ast.expr) ->
     patt_filter:('b -> Ast.patt) ->
       mexpr:(FanLoc.t -> 'c -> 'a) ->
         mpatt:(FanLoc.t -> 'c -> 'b) -> 
           string ->
             'c Gram.t  ->  unit

val add_quotation_of_expr: name:string -> entry:Ast.expr Gram.t -> unit

val add_quotation_of_patt: name:string -> entry:Ast.patt Gram.t -> unit

val add_quotation_of_class_str_item:
  name:string -> entry:Ast.class_str_item Gram.t -> unit
      
val add_quotation_of_match_case:
  name:string -> entry:Ast.match_case Gram.t -> unit
      
val add_quotation_of_str_item: name:string -> entry:Ast.str_item Gram.t -> unit

val current_loc_name: string option ref     