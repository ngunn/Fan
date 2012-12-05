open LibUtil
  
type 'a t 

type assoc = [ `LA | `NA | `RA ]

type position =
    [ `After of string
    | `Before of string
    | `First
    | `Last
    | `Level of string ]

type gram =
  Grammar.Structure.gram = {
  gfilter : FanTokenFilter.filter;
  gkeywords : (string, int ref) Hashtbl.t;
  glexer : FanLoc.t -> char Stream.t -> (FanToken.token * FanLoc.t) Stream.t;
  warning_verbose : bool ref;
  error_verbose : bool ref;
}
type token_info =
  Grammar.Structure.token_info = {
  prev_loc : FanLoc.t;
  cur_loc : FanLoc.t;
  prev_loc_only : bool;
}


module Action :
  sig
    type t = Grammar.Structure.Action.t
    val mk : 'a -> t
    val get : t -> 'a
    val getf : t -> 'a -> 'b
    val getf2 : t -> 'a -> 'b -> 'c
  end
type token_stream = (FanToken.token * token_info) Stream.t
type description = [ `Antiquot | `Normal ]
type descr = description * string
type token_pattern = (FanToken.token -> bool) * descr
type internal_entry = Grammar.Structure.internal_entry 
and desc = Grammar.Structure.desc
and level = Grammar.Structure.level 
and symbol = Grammar.Structure.symbol
and tree = Grammar.Structure.tree 
and node =  Grammar.Structure.node 

type production = symbol list * Action.t
type olevel = string option * assoc option * production list
type extend_statment = position option * olevel list
type delete_statment = symbol list

type ('a,'b,'c)fold  =
    'b t->
      symbol list->
        ('a Stream.t  -> 'b) -> 'a Stream.t  -> 'c

type ('a,'b,'c) foldsep  =
   'b t ->
     symbol list ->
       ('a Stream.t -> 'b) ->
         ('a Stream.t -> unit) ->
           'a Stream.t -> 'c
      


      
val name : 'a t -> string
val print : Format.formatter -> 'a t -> unit
val dump : Format.formatter -> 'a t -> unit
val trace_parser : bool ref
val action_parse:
  'a t ->  token_stream -> Action.t
val parse_origin_tokens :
  'a t -> token_stream -> 'a
val setup_parser :
  'a t ->
  ((FanToken.token * token_info) Stream.t -> 'a) -> unit
val clear : 'a t -> unit
val ghost_token_info : token_info
val token_location : token_info -> FanLoc.t
val using : gram -> string -> unit
val mk_action : 'a -> Action.t

val string_of_token:[>FanToken.token] -> string

val obj : 'a t -> internal_entry         
val removing : gram -> string -> unit
val gram: gram
val create_gram: unit -> gram
val mk_dynamic: gram -> string -> 'a t
val mk: string -> 'a t
val of_parser :
  string ->
  ((FanToken.token * token_info) Stream.t -> 'a) ->
  'a t
val get_filter : unit -> FanTokenFilter.filter
val lex : FanLoc.t -> char Stream.t -> (FanToken.token * FanLoc.t) Stream.t
val lex_string : FanLoc.t -> string -> (FanToken.token * FanLoc.t) Stream.t
val filter :
  (FanToken.token * FanLoc.t) Stream.t ->
  (FanToken.token * token_info) LibUtil.Stream.t
(* val filter_and_parse_tokens : *)
(*   'a t -> *)
(*   (FanToken.token * FanLoc.t) Stream.t -> 'a *)
val parse :
  'a t -> FanLoc.t -> char Stream.t -> 'a
val parse_string :
  'a t -> FanLoc.t -> string -> 'a
val debug_origin_token_stream : 'a t -> FanToken.token Stream.t -> 'a
val debug_filtered_token_stream :
  'a t -> FanToken.token Stream.t -> 'a
val parse_string_safe :
  'a t -> FanLoc.t -> string -> 'a
val wrap_stream_parser : ('a -> 'b -> 'c) -> 'a -> 'b -> 'c
val parse_file_with : rule:'a t -> string -> 'a
val delete_rule :
  'a t -> symbol list -> unit
val srules :
  'a t ->
  (symbol list * Action.t) list ->
  [> `Stree of tree ]
val sfold0 :
  ('a -> 'b -> 'b) ->
  'b -> 'c -> 'd -> ('e Stream.t -> 'a) -> 'e Stream.t -> 'b
val sfold1 :
  ('a -> 'b -> 'b) ->
  'b -> 'c -> 'd -> ('e Stream.t -> 'a) -> 'e Stream.t -> 'b
      
val sfold0sep :
    ('a -> 'b -> 'b) ->  'b ->
    'a t ->
    symbol list ->
    ('c Stream.t -> 'a) ->
      ('c Stream.t -> unit) ->
        'c Stream.t -> 'b
val extend :
  'a t -> extend_statment -> unit
val eoi_entry : 'a t -> 'a t

    
val levels_of_entry: 'a t -> level list option
val find_level:
    ?position:position ->  'a t -> level
val token_stream_of_string: string -> (FanToken.token * Grammar.Structure.token_info) LibUtil.Stream.t
