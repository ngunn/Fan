open Structure;
open LibUtil;
open FanToken;

(* [bp] means begining position, [ep] means ending position
   apply the [parse_fun] and get the result and the location of
   consumed areas
 *)
let add_loc bp (parse_fun: parse 'b) strm =
  let x = parse_fun strm in
  let ep = Tools.get_prev_loc strm in
  let loc =
    if FanLoc.start_off bp > FanLoc.stop_off ep then
      (* If nothing has been consumed, create a 0-length location. *)
      FanLoc.join bp
    else
      FanLoc.merge bp ep in
  (x, loc);


(* given a level string, return a number from 0
   {[
   Parser.level_number (Obj.magic expr) "top";
   - : int = 0
   Parser.level_number (Obj.magic expr) "simple";
   - : int = 16
   ]}
 *)  
let level_number entry lab =
  let rec lookup levn = fun
    [ [] -> failwithf "unknown level %s"  lab
    | [lev :: levs] ->
        if Tools.is_level_labelled lab lev then levn else lookup (succ levn) levs ] in
  match entry.edesc with
  [ Dlevels elev -> lookup 0 elev
  | Dparser _ -> raise Not_found ] ;
    

(* in case of syntax error, the system attempts to recover the error by applying
   the [continue] function of the previous symbol(if the symbol is a call to an entry),
   so there's no behavior difference between [LA] and [NA]
 *)
    

(*
  It outputs a stateful parser, but it is functional itself
 *)    
let rec parser_of_tree entry (lev,assoc) (q: Queue.t Action.t) x =
  let alevn = match assoc with
    [`LA|`NA -> lev + 1 | `RA -> lev ] in
  (*
    Given a tree, return a parser which has the type
    [parse Action.t]. Think about [node son], only son owns the action,
    so the action returned by son is a function,
    it is to be applied by the value returned by node.
   *)
  let rec from_tree tree =  match tree  with
  [ DeadEnd ->
    raise XStream.Failure (* FIXME be more preicse *)
  | LocAct (act, _) ->
      fun _ -> act 
  (* rules ending with [SELF] , for this last symbol there's a call to the [start] function:
     of the current level if the level is [`RA] or of the next level otherwise. (This can be
     verified by [start_parser_of_levels]) *)      
  | Node {node = `Sself; son = LocAct (act, _); brother = bro} ->  fun strm ->
      let try a =entry.estart alevn strm in begin
        Queue.push a q ;
        act
      end
      with [XStream.Failure -> from_tree bro strm]
  (* [son] will never be [DeadEnd] *)        
  | Node ({ node ; son; brother } as y) ->
      (*
        Handle the problem
        {[
        `-OPT assoc---rule_list---.
        `-OPT [ `STR (_,_)]---OPT assoc---rule_list---.
        ]}
       *)
      match Tools.get_terminals  y with
      [ None ->
        (* [paser_of_symbol] given a stream should always return a value  *) 
        let ps = parser_of_symbol entry node  lev  in fun strm ->
          let bp = Tools.get_cur_loc strm in
          let try a = ps strm in
          let pson = from_tree son in
          let try v = pson strm in begin
            Queue.push a q;
            v
          end
          with
            [XStream.Failure ->
              if Tools.get_cur_loc strm = bp  then
                raise XStream.Failure
              else
                raise (XStream.Error (Failed.tree_failed entry a node son))]
          with
            [XStream.Failure -> from_tree brother strm]
      | Some (tokl, _node, son) -> fun strm ->
          let try (args,action) =
            parser_of_terminals tokl (from_tree son) strm in 
            (List.iter (fun a -> Queue.push (Action.mk a) q) args; action)
          (* try parser_of_terminals tokl (from_tree son) strm *)
          with [XStream.Failure -> from_tree brother strm] ] ] in
  let parse = from_tree x in
  fun strm -> 
    let parse =  parse strm in
    let ans = Queue.fold (fun q arg -> Action.getf q arg) parse q in
    (Queue.clear q; ans)

(*
  {[
  let a : FanToken.t = Obj.magic & Parser.parser_of_terminals
  [`Skeyword "a";`Skeyword "b"; `Skeyword "c"]
  (fun _ v _  -> Action.mk (fun  c b a ->  v))
  [< (`KEYWORD "a",_loc) ; (`KEYWORD "b", _loc); (`KEYWORD "c",_loc) >];
  val a : FanToken.t = `KEYWORD "c"
  ]}
 *)    
and parser_of_terminals
    (terminals:list terminal ) (cont:parse Action.t) strm =
  let n = List.length terminals in
  let acc = ref [] in begin
    try
      List.iteri
          (fun i terminal  -> 
            let t =
              match XStream.peek_nth strm i with
              [Some (tok,_) -> tok
              |None -> invalid_arg "parser_of_terminals"] in
            begin
              acc:= [t::!acc];
              if not
                  (match terminal with
                    [`Stoken(f,_) -> f t
                    |`Skeyword kwd -> FanToken.match_keyword kwd t])
              then
                invalid_arg "parser_of_terminals"
            end) terminals (* tokens *)
    with [Invalid_argument _ -> raise XStream.Failure];

    XStream.njunk n strm;
    let action = (cont  strm);
    (!acc,action)    
  end          
(* only for [Smeta] it might not be functional *)
and parser_of_symbol entry s nlevn =
  let rec aux s = 
    match s with 
   [ `Smeta (_, symbls, act) ->
     let act = Obj.magic act entry symbls
     and pl = List.map aux symbls in
     Obj.magic (List.fold_left (fun act p -> Obj.magic act p) act pl)
   | `Slist0 s ->
     let ps = aux s in  Comb.slist0 ps ~f:(fun l -> Action.mk (List.rev l))
   | `Slist0sep (symb, sep) ->
     let ps = aux symb and pt =  aux sep  in
     Comb.slist0sep ps pt ~err:(fun v -> Failed.symb_failed entry v sep symb)
       ~f:(fun l -> Action.mk (List.rev l))
   | `Slist1 s -> let ps =  aux s  in
     Comb.slist1 ps ~f:(fun l -> Action.mk (List.rev l))
   | `Slist1sep (symb, sep) ->
       let ps = aux symb and pt = aux sep  in
       Comb.slist1sep ps pt ~err:(fun v -> Failed.symb_failed entry v sep symb)
         ~f:(fun l -> Action.mk (List.rev l))
  | `Sopt s -> let ps = aux s  in Comb.opt ps ~f:Action.mk
  | `Stry s -> let ps = aux s in Comb.tryp ps
  | `Speek s -> let ps = aux s in Comb.peek ps
  | `Stree t ->
      let pt = parser_of_tree entry (0, `RA)  (Queue.create ())t (* FIXME*) in
      fun strm ->
        let bp = Tools.get_cur_loc strm in
        let (act,loc) = add_loc bp pt strm in Action.getf act loc
  | `Snterm e -> fun strm -> e.estart 0 strm  (* No filter any more *)
  | `Snterml (e, l) -> fun strm -> e.estart (level_number e l) strm
  | `Sself -> fun strm -> entry.estart 0 strm 
  | `Snext -> fun strm -> entry.estart (nlevn + 1 ) strm 
  | `Skeyword kwd -> fun strm ->
        match XStream.peek strm with
        [Some (tok,_) when FanToken.match_keyword kwd tok -> begin XStream.junk strm ; Action.mk tok end
        |_ -> raise XStream.Failure ]
  | `Stoken (f, _) -> fun strm ->
      match XStream.peek strm with
      [Some (tok,_) when f tok -> (XStream.junk strm; Action.mk tok)
      |_ -> raise XStream.Failure]] in aux s;



(* entrance for the start
   [clevn] is the current level 
 *)  
let start_parser_of_levels entry =
  let rec aux clevn  (xs: list level) : int -> parse Action.t =
    match xs with 
    [ [] -> fun _ -> fun _ -> raise XStream.Failure  
    | [lev :: levs] ->
        let hstart = aux  (clevn+1) levs in
        match lev.lprefix with
        [ DeadEnd -> hstart (* try the upper levels *)
        | tree ->
          let cstart = 
            parser_of_tree entry (clevn, lev.assoc) (Queue.create ())tree  in
          (* the [start] function tires its associated tree. If it works
             it calls the [continue] function of the same level, giving the
             result of [start] as parameter.
             If this continue fails, the parameter is simply returned.
             If this [start] function fails, the start function of the
             next level is tested, if there is no more levels, the parsing fails
           *)    
          fun levn strm ->
            if levn > clevn && (not ([]=levs))then
              hstart levn strm (* only higher level allowed here *)
            else
              let bp = Tools.get_cur_loc strm in
              let try (act,loc) = add_loc bp cstart strm in
              let a = Action.getf act loc in
              entry.econtinue levn loc a strm
              with [XStream.Failure -> hstart levn strm]] ] in
  aux 0;
  
let start_parser_of_entry entry =
  match entry.edesc with
  [ Dlevels [] -> Tools.empty_entry entry.ename
  | Dlevels elev -> start_parser_of_levels entry  elev
  | Dparser p -> fun _ -> p ] ;
    


let rec continue_parser_of_levels entry clevn = fun
  [ [] -> fun _ _ _ ->  fun _ -> raise XStream.Failure
  | [lev :: levs] ->
      let hcontinue = continue_parser_of_levels entry  (clevn+1) levs in
      match lev.lsuffix with
      [ DeadEnd -> hcontinue
          (* the continue function first tries the [continue] function of the next level,
             if it fails or if it's the last level, it tries its associated tree, then
             call itself again, giving the result as parameter. If the associated tree
             fails, it returns its extra parameter
           *)
      | tree ->
        let ccontinue = parser_of_tree entry (clevn, lev.assoc) (Queue.create ()) tree in
        fun levn bp a strm ->
          if levn > clevn then
            hcontinue levn bp a strm
          else
            try hcontinue levn bp a strm
            with
            [XStream.Failure ->
              let (act,loc) = add_loc bp ccontinue strm in
              let a = Action.getf2 act a loc in entry.econtinue levn loc a strm]] ];

  
let continue_parser_of_entry entry =
  (* debug gram "continue_parser_of_entry: @[<2>%a@]@." Print.text#entry entry in *)
  match entry.edesc with
  [ Dlevels elev ->
    let p = continue_parser_of_levels entry 0 elev in
    fun levn bp a strm -> try p levn bp a strm with XStream.Failure -> a 
  | Dparser _ -> fun _ _ _ _ -> raise XStream.Failure  ];

