open Automata_def
open Tag_regexp
type concrete_regexp =  
  | Epsilon
  | Eof
  | Characters of Cset.t
  | Sequence of concrete_regexp* concrete_regexp
  | Alternative of concrete_regexp* concrete_regexp
  | Repetition of concrete_regexp
  | Bind of concrete_regexp* (Locf.t* string) 
type 'a entry =  {
  shortest: bool;
  clauses: (concrete_regexp* 'a) list} 
let regexp_for_string s =
  let rec re_string n =
    let len = String.length s in
    if n >= len
    then Epsilon
    else
      if (n + 1) = len
      then Characters (Cset.singleton (Char.code (s.[n])))
      else
        Sequence
          ((Characters (Cset.singleton (Char.code (s.[n])))),
            (re_string (n + 1))) in
  re_string 0
let rec remove_as x =
  match x with
  | Bind (e,_) -> remove_as e
  | Epsilon |Eof |Characters _ as e -> e
  | Sequence (e1,e2) -> Sequence ((remove_as e1), (remove_as e2))
  | Alternative (e1,e2) -> Alternative ((remove_as e1), (remove_as e2))
  | Repetition e -> Repetition (remove_as e)
exception Bad
let as_cset = function | Characters s -> s | _ -> raise Bad
let remove_nested_as e =
  (let rec do_remove_nested (to_remove : Id_set.t) x =
     (match x with
      | Bind (e,x) ->
          if Id_set.mem x to_remove
          then do_remove_nested to_remove e
          else Bind ((do_remove_nested (Id_set.add x to_remove) e), x)
      | Epsilon |Eof |Characters _ as e -> e
      | Sequence (e1,e2) ->
          Sequence
            ((do_remove_nested to_remove e1),
              (do_remove_nested to_remove e2))
      | Alternative (e1,e2) ->
          Alternative
            ((do_remove_nested to_remove e1),
              (do_remove_nested to_remove e2))
      | Repetition e -> Repetition (do_remove_nested to_remove e) : concrete_regexp ) in
   do_remove_nested Id_set.empty e : concrete_regexp )
let rec find_all_vars (x : concrete_regexp) =
  (let open Id_set in
     match x with
     | Characters _|Epsilon |Eof  -> empty
     | Bind (e,x) -> add x (find_all_vars e)
     | Sequence (e1,e2)|Alternative (e1,e2) ->
         union (find_all_vars e1) (find_all_vars e2)
     | Repetition e -> find_all_vars e : Id_set.t )
let find_optional e =
  let rec do_find_opt x =
    (let open Id_set in
       match x with
       | Characters _|Epsilon |Eof  -> (empty, empty)
       | Bind (e,x) -> let (opt,all) = do_find_opt e in (opt, (add x all))
       | Sequence (e1,e2) ->
           let (opt1,all1) = do_find_opt e1 and (opt2,all2) = do_find_opt e2 in
           ((union opt1 opt2), (union all1 all2))
       | Alternative (e1,e2) ->
           let (opt1,all1) = do_find_opt e1 and (opt2,all2) = do_find_opt e2 in
           ((union (union opt1 opt2)
               (union (diff all1 all2) (diff all2 all1))), (union all1 all2))
       | Repetition e -> let r = find_all_vars e in (r, r) : (Id_set.t*
                                                               Id_set.t) ) in
  fst @@ (do_find_opt e)
let rec do_find_double x =
  (let open Id_set in
     match x with
     | Characters _|Epsilon |Eof  -> (empty, empty)
     | Bind (e,x) ->
         let (dbl,all) = do_find_double e in
         ((if mem x all then add x dbl else dbl), (add x all))
     | Sequence (e1,e2) ->
         let (dbl1,all1) = do_find_double e1
         and (dbl2,all2) = do_find_double e2 in
         ((union (inter all1 all2) (union dbl1 dbl2)), (union all1 all2))
     | Alternative (e1,e2) ->
         let (dbl1,all1) = do_find_double e1
         and (dbl2,all2) = do_find_double e2 in
         ((union dbl1 dbl2), (union all1 all2))
     | Repetition e -> let r = find_all_vars e in (r, r) : (Id_set.t*
                                                             Id_set.t) )
let find_double e = do_find_double e
let add_some x = function | Some i -> Some (x + i) | None  -> None
let add_some_some x y =
  match (x, y) with | (Some i,Some j) -> Some (i + j) | (_,_) -> None
let find_chars e =
  let open Id_set in
    let rec do_find_chars (sz : int option) x =
      match x with
      | Epsilon |Eof  -> (empty, empty, sz)
      | Characters _ -> (empty, empty, (add_some 1 sz))
      | Bind (e,x) ->
          let (c,s,e_sz) = do_find_chars (Some 0) e in
          (match e_sz with
           | Some 1 -> ((add x c), s, (add_some 1 sz))
           | _ -> (c, (add x s), (add_some_some sz e_sz)))
      | Sequence (e1,e2) ->
          let (c1,s1,sz1) = do_find_chars sz e1 in
          let (c2,s2,sz2) = do_find_chars sz1 e2 in
          ((union c1 c2), (union s1 s2), sz2)
      | Alternative (e1,e2) ->
          let (c1,s1,sz1) = do_find_chars sz e1
          and (c2,s2,sz2) = do_find_chars sz e2 in
          ((union c1 c2), (union s1 s2), (if sz1 = sz2 then sz1 else None))
      | Repetition e -> do_find_chars None e in
    let (c,s,_) = do_find_chars (Some 0) e in diff c s
let chars = ref ([] : Cset.t list )
let chars_count = ref 0
let rec encode_regexp (char_vars : Id_set.t) (act : int) x =
  (match x with
   | Epsilon  -> Empty
   | Characters cl ->
       let n = !chars_count in
       (chars := (cl :: (!chars)); incr chars_count; Chars (n, false))
   | Eof  ->
       let n = !chars_count in
       (chars := (Cset.eof :: (!chars)); incr chars_count; Chars (n, true))
   | Sequence (r1,r2) ->
       let r1 = encode_regexp char_vars act r1 in
       let r2 = encode_regexp char_vars act r2 in Seq (r1, r2)
   | Alternative (r1,r2) ->
       let r1 = encode_regexp char_vars act r1 in
       let r2 = encode_regexp char_vars act r2 in Alt (r1, r2)
   | Repetition r -> Star (encode_regexp char_vars act r)
   | Bind (r,((_,name) as y)) ->
       let r = encode_regexp char_vars act r in
       if Id_set.mem y char_vars
       then Seq ((Tag { id = name; start = true; action = act }), r)
       else
         Seq
           ((Tag { id = name; start = true; action = act }),
             (Seq (r, (Tag { id = name; start = false; action = act })))) : 
  regexp )
let mk_seq (r1 : regexp) (r2 : regexp) =
  (match (r1, r2) with
   | (Empty ,_) -> r2
   | (_,Empty ) -> r1
   | _ -> Seq (r1, r2) : regexp )
let add_pos p i =
  match (p : Automata_def.tag_addr option ) with
  | Some (a,n) -> Some (a, (n + i))
  | None  -> None
let mem_name name (id_set : Id_set.t) =
  (Id_set.exists (fun (_,id_name)  -> name = id_name) id_set : bool )
let rec size_forward pos (x : regexp) =
  (match x with
   | Empty |Chars (_,true )|Tag _ -> Some pos
   | Chars (_,false ) -> Some (pos + 1)
   | Seq (r1,r2) ->
       (match size_forward pos r1 with
        | None  -> None
        | Some pos -> size_forward pos r2)
   | Alt (r1,r2) ->
       let pos1 = size_forward pos r1 and pos2 = size_forward pos r2 in
       if pos1 = pos2 then pos1 else None
   | Star _ -> None
   | Action _ -> assert false : int option )
let rec size_backward pos (x : regexp) =
  match x with
  | Empty |Chars (_,true )|Tag _ -> Some pos
  | Chars (_,false ) -> Some (pos - 1)
  | Seq (r1,r2) ->
      (match size_backward pos r2 with
       | None  -> None
       | Some pos -> size_backward pos r1)
  | Alt (r1,r2) ->
      let pos1 = size_backward pos r1 and pos2 = size_backward pos r2 in
      if pos1 = pos2 then pos1 else None
  | Star _ -> None
  | Action _ -> assert false
let opt_regexp all_vars char_vars optional_vars double_vars (r : regexp) =
  (let env = Hashtbl.create 17 in
   let rec simple_forward pos r double_vars =
     match r with
     | Tag n ->
         if mem_name n.id double_vars
         then (r, (Some pos))
         else
           (Hashtbl.add env ((n.id), (n.start)) (Start, pos);
            (Empty, (Some pos)))
     | Empty  -> (r, (Some pos))
     | Chars (_,is_eof) -> (r, (Some (if is_eof then pos else pos + 1)))
     | Seq (r1,r2) ->
         (match simple_forward pos r1 double_vars with
          | (r1,None ) -> ((mk_seq r1 r2), None)
          | (r1,Some pos) ->
              let (r2,pos) = simple_forward pos r2 double_vars in
              ((mk_seq r1 r2), pos))
     | Alt (r1,r2) ->
         let pos1 = size_forward pos r1 and pos2 = size_forward pos r2 in
         (r, (if pos1 = pos2 then pos1 else None))
     | Star _ -> (r, None)
     | Action _ -> assert false in
   let rec simple_backward pos r double_vars =
     match r with
     | Tag n ->
         if mem_name n.id double_vars
         then (r, (Some pos))
         else
           (Hashtbl.add env ((n.id), (n.start)) (End, pos);
            (Empty, (Some pos)))
     | Empty  -> (r, (Some pos))
     | Chars (_,is_eof) -> (r, (Some (if is_eof then pos else pos - 1)))
     | Seq (r1,r2) ->
         (match simple_backward pos r2 double_vars with
          | (r2,None ) -> ((mk_seq r1 r2), None)
          | (r2,Some pos) ->
              let (r1,pos) = simple_backward pos r1 double_vars in
              ((mk_seq r1 r2), pos))
     | Alt (r1,r2) ->
         let pos1 = size_backward pos r1 and pos2 = size_backward pos r2 in
         (r, (if pos1 = pos2 then pos1 else None))
     | Star _ -> (r, None)
     | Action _ -> assert false in
   let r =
     let (r,_) = simple_forward 0 r double_vars in
     let (r,_) = simple_backward 0 r double_vars in r in
   let loc_count = ref 0 in
   let get_tag_addr t =
     try Hashtbl.find env t
     with
     | Not_found  ->
         let n = !loc_count in
         (incr loc_count; Hashtbl.add env t ((Mem n), 0); ((Mem n), 0)) in
   let rec alloc_exp pos r =
     match r with
     | Tag n ->
         if mem_name n.id double_vars
         then (r, pos)
         else
           (match pos with
            | Some a -> (Hashtbl.add env ((n.id), (n.start)) a; (Empty, pos))
            | None  ->
                let a = get_tag_addr ((n.id), (n.start)) in (r, (Some a)))
     | Empty  -> (r, pos)
     | Chars (_,is_eof) -> (r, (if is_eof then pos else add_pos pos 1))
     | Seq (r1,r2) ->
         let (r1,pos) = alloc_exp pos r1 in
         let (r2,pos) = alloc_exp pos r2 in ((mk_seq r1 r2), pos)
     | Alt (_,_) ->
         let off = size_forward 0 r in
         (match off with
          | Some i -> (r, (add_pos pos i))
          | None  -> (r, None))
     | Star _ -> (r, None)
     | Action _ -> assert false in
   let (r,_) = alloc_exp None r in
   let m =
     Id_set.fold
       (fun ((_,name) as x)  r  ->
          let v =
            if Id_set.mem x char_vars
            then
              Ident_char
                ((Id_set.mem x optional_vars), (get_tag_addr (name, true)))
            else
              Ident_string
                ((Id_set.mem x optional_vars), (get_tag_addr (name, true)),
                  (get_tag_addr (name, false))) in
          (x, v) :: r) all_vars [] in
   (m, r, (!loc_count)) : ((Id_set.elt* ident_info) list* regexp* int) )
let encode_casedef (regexps : (concrete_regexp* 'a) list) =
  List.fold_left
    (fun (reg,actions,count,ntags)  (expr,act)  ->
       let expr = remove_nested_as expr in
       let char_vars = find_chars expr in
       let opt_vars = find_optional expr in
       let (double_vars,all_vars) = find_double expr in
       let r = encode_regexp char_vars count expr in
       let (m,r,loc_ntags) =
         opt_regexp all_vars char_vars opt_vars double_vars r in
       ((Alt (reg, (Seq (r, (Action count))))), ((count, m, act) :: actions),
         (count + 1), (max loc_ntags ntags))) (Empty, [], 0, 0) regexps
let reset () = chars := []; chars_count := 0
type 'a lexer_entry = 
  {
  lex_regexp: regexp;
  lex_mem_tags: int;
  lex_actions: (int* t_env* 'a) list} 
let encode_lexdef (def : 'a entry list) =
  (reset ();
   (let entry_list =
      List.map
        (fun { shortest; clauses }  ->
           let (lex_regexp,actions,_,lex_mem_tags) = encode_casedef clauses in
           ({ lex_regexp; lex_mem_tags; lex_actions = (List.rev actions) },
             shortest)) def in
    ((Array.of_list (List.rev (!chars))), entry_list)) : (Cset.t array* ('a
                                                           lexer_entry* bool)
                                                           list) )
let encode_single_lexdef (def : 'a entry) =
  (reset ();
   (let result =
      match def with
      | { shortest; clauses } ->
          let (lex_regexp,actions,_,lex_mem_tags) = encode_casedef clauses in
          ({ lex_regexp; lex_mem_tags; lex_actions = (List.rev actions) },
            shortest) in
    ((Array.of_list (List.rev (!chars))), result)) : (Cset.t array* ('a
                                                       lexer_entry* bool)) )
