
type assoc =
    [ `NA|`RA|`LA]
type position =
    [ `First | `Last | `Before of string | `After of string | `Level of string]



(* the [location] and the parsed value *)
type 'a cont_parse  = Locf.t -> Gaction.t -> 'a Ftoken.parse 
    
(** Duplicated in fgram.mli *)
type loc = Locf.t
type ant = [ `Ant of (loc* FanUtil.anti_cxt)]
type vid = [ `Dot of (vid* vid) | `Lid of string | `Uid of string | ant] 
type any = [ `Any]
type alident = [ `Lid of string | ant] 
type auident = [ `Uid of string | ant] 
type ident =
  [ `Dot of (ident* ident) | `Apply of (ident* ident) | alident | auident] 
type literal =
  [ `Chr of string | `Int of string | `Int32 of string | `Int64 of string
  | `Flo of string | `Nativeint of string | `Str of string]



(** a simplified pattern compared with [FAstN.pat], used as
    runtime description for token *)      
type pat =
  [ vid | `App of (pat* pat) | `Vrn of string | `Com of (pat* pat)
  | `Sem of (pat* pat) | `Par of pat | any | `Record of rec_pat | literal
  | `Alias of (pat* alident) | `ArrayEmpty | `Array of pat
  | `Bar of (pat* pat)
  | `PaRng of (pat* pat) ] 

and rec_pat =
  [ `RecBind of (ident* pat) | `Sem of (rec_pat* rec_pat) | any | ant] 
      
      
(* ATTENTION: the type system can not guarantee it would compile *)      
(* type descr = pat *)
type word =
   [`Any
   |`A of string
   |`Empty]
and data = (string * word) (* FIXME duplicate in gram_def *)      
type descr = data
    
type token_pattern = (Ftoken.t -> bool) * descr * string
(** [arg1] is used for runtime parsing, generated at compile time

    [arg2] is used for runtime merging, generated at compile time

    [arg3] is used for
    runtime error message and pretty printing,
    it could be removed later.
 *)



(** all variants [Ftoken.t] is normalized into two patterns, either a keyword or
    a generalized token *)      
type terminal =
    [ `Skeyword of string
    | `Stoken of token_pattern ]
  
type gram = {
    annot : string;
    gfilter         : FanTokenFilter.t;
  }

type label =  string option

    
type entry = {
    gram     : gram;
    name     : string;
    mutable start    :  int -> Gaction.t Ftoken.parse ;
    mutable continue : int -> Gaction.t cont_parse ;
    mutable desc     :  desc;
    mutable freezed :  bool;}
and desc =
  | Dlevels of level list 
  | Dparser of (Ftoken.stream -> Gaction.t )
and level = {
    lname   : label;
    assoc   : assoc ;
    productions : production list ;
   (* (assoc, lname, production) triple composes
      olevel which can be used by [Ginsert.level_of_olevel]
      to deduce  the whole level *)
    (* the raw productions stored in the level*)
    lsuffix : tree ;
    lprefix : tree}
and asymbol =
  [ `Snterm of entry
  | `Snterml of (entry * string) (* the second argument is the level name *)
  | `Slist0 of symbol
  | `Slist1 of symbol
  | `Sopt of symbol
  | `Stry of symbol
  | `Speek of symbol
  | `Sself
  | `Slist0sep of (symbol * symbol)        
  | `Slist1sep of (symbol * symbol)      
  | terminal ]  
and symbol =
  [
    `Snterm of entry
  | `Snterml of (entry * string) (* the second argument is the level name *)
  | `Slist0 of symbol
  | `Slist0sep of (symbol * symbol)
  | `Slist1 of symbol
  | `Slist1sep of (symbol * symbol)
  | `Sopt of symbol
  | `Stry of symbol
  | `Speek of symbol
  | `Sself
  | terminal
 ]
      
and tree = (* internal struccture *)
  | Node of node
  | LocAct of anno_action *  anno_action list
  | DeadEnd 
and node = {
    node    : symbol ;
    son     : tree   ;
    brother : tree   }
and production= symbol list  *   (string * Gaction.t)

(* number * symbols * action_as_tring * action *)
and anno_action = (int  * symbol list  * string  * Gaction.t) 



(* FIXME duplciate with Fgram.mli*)

(**
   [olevel] is the [processed output] from the Fgram DDSL, the runtime representation
   is [level], there is a function [Ginsert.level_of_olevel] which converts the
   processed output into the runtime
 *)      
type olevel = (label * assoc option  * production list )
type extend_statment = (position option  * olevel list )
type single_extend_statement =  (position option  * olevel)
type delete_statment = symbol list 



  

(* local variables: *)
(* compile-command: "cd .. &&  pmake treeparser/gstructure.cmo" *)
(* end: *)
