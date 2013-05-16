open LibUtil

open FanToken

type assoc = [ `NA | `RA | `LA] 

type position =
  [ `First | `Last | `Before of string | `After of string | `Level of string] 

type 'a cont_parse = FanLoc.t -> Gaction.t -> 'a parse 

type description = [ `Normal | `Antiquot] 

type descr = (description * string) 

type token_pattern = ((FanToken.t -> bool) * descr) 

type terminal = [ `Skeyword of string | `Stoken of token_pattern] 

type gram =  {
  annot: string;
  gfilter: FanTokenFilter.t;
  gkeywords: SSet.t ref} 

type label = string option 

type entry = 
  {
  egram: gram;
  ename: string;
  mutable estart: int -> Gaction.t parse;
  mutable econtinue: int -> Gaction.t cont_parse;
  mutable edesc: desc;
  mutable freezed: bool} 
and desc =  
  | Dlevels of level list
  | Dparser of (stream -> Gaction.t) 
and level = 
  {
  assoc: assoc;
  lname: label;
  productions: production list;
  lsuffix: tree;
  lprefix: tree} 
and symbol =
  [ `Smeta of (string list * symbol list * Gaction.t) | `Snterm of entry
  | `Snterml of (entry * string) | `Slist0 of symbol
  | `Slist0sep of (symbol * symbol) | `Slist1 of symbol
  | `Slist1sep of (symbol * symbol) | `Sopt of symbol | `Stry of symbol
  | `Speek of symbol | `Sself | `Snext | `Stree of tree | terminal] 
and tree =  
  | Node of node
  | LocAct of anno_action* anno_action list
  | DeadEnd 
and node =  {
  node: symbol;
  son: tree;
  brother: tree} 
and production = (symbol list * (string * Gaction.t)) 
and anno_action = (int * symbol list * string * Gaction.t) 

type olevel = (label * assoc option * production list) 

type extend_statment = (position option * olevel list) 

type single_extend_statement = (position option * olevel) 

type delete_statment = symbol list 

type space_formatter = (unit,Format.formatter,unit) format 