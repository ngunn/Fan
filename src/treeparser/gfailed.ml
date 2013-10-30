

open Gstructure



open Format

let pp = fprintf 

  
let  name_of_symbol entry : [> symbol] -> string  =  function
  | `Nterm e -> "[" ^ e.name ^ "]"
  | `Snterml (e, l) -> "[" ^ e.name ^ " level " ^ l ^ "]"
  | `Self  -> "[" ^ entry.name ^ "]"
  | `Token (_, _,descr) -> descr
  | `Keyword kwd -> "\"" ^ kwd ^ "\""
  | _ -> "???" 

let tree_in_entry prev_symb tree = function
  | Dlevels levels ->
      let rec search_level level =
        match search_tree level.lsuffix with
        | Some t -> Some (Node {node = `Self; son = t; brother = DeadEnd})
        | None -> search_tree level.lprefix 
      and search_tree t =
        if tree <> DeadEnd && t == tree then (* physical equivality*)
          Some t
        else
          match t with
          | Node n ->
              begin match search_symbol n.node with
              |Some symb ->
                  Some (Node {node = symb; son = n.son; brother = DeadEnd})
              | None ->
                  begin match search_tree n.son with
                  | Some t ->
                      Some (Node {node = n.node; son = t; brother = DeadEnd})
                  | None -> search_tree n.brother
                  end
              end
          | LocAct (_, _) | DeadEnd -> None 
      and search_symbol symb =
        match symb with
        | `Nterm _ | `Snterml (_, _) | `List0 _ | `List0sep (_, _) | `List1 _ |
          `List1sep (_, _)  | `Try _ | `Token _ | `Keyword _
        | `Peek _
          when symb == prev_symb ->
            Some symb
        | `List0 symb ->
            begin match search_symbol symb with
            | Some symb -> Some (`List0 symb)
            | None -> None
            end
        | `List0sep (symb, sep) ->
            begin match search_symbol symb with
            | Some symb -> Some (`List0sep (symb, sep))
            | None ->
                match search_symbol sep with
                | Some sep -> Some (`List0sep (symb, sep))
                | None -> None 
            end
        | `List1 symb ->
            begin match search_symbol symb with
            | Some symb -> Some (`List1 symb)
            | None -> None
            end
        | `List1sep (symb, sep) ->
            begin match search_symbol symb with
            | Some symb -> Some (`List1sep (symb, sep))
            | None ->
                match search_symbol sep with
                | Some sep -> Some (`List1sep (symb, sep))
                | None -> None 
            end
        | `Try symb ->
            begin match search_symbol symb with
            | Some symb -> Some (`Try symb)
            | None -> None
            end
        | `Peek symb ->
            begin match search_symbol symb with
            | Some symb -> Some (`Peek symb)
            | None -> None
            end
        | _ -> None  in
      (match Listf.find_map search_level  levels with
      | Some x -> x
      | None -> tree)
  | Dparser _ -> tree 

        
(* error message entrance *)
let rec name_of_symbol_failed entry  = function
  | `List0 s | `List0sep (s, _)
  | `List1 s | `List1sep (s, _)
  | `Try s | `Peek s  ->
      name_of_symbol_failed entry s
  | s -> name_of_symbol entry s
and name_of_tree_failed entry x =
  match x with 
  | Node ({node ; brother; _ (* son = son *)} as y)->
      begin match Gtools.get_terminals y  with
      | None ->
          let txt = name_of_symbol_failed entry node in
          (* let txt = *)
          (*   match (node, son) with (\* when the current node is Opt *\) *)
          (*   | (`Opt _, Node _) -> txt ^ " or " ^ name_of_tree_failed entry son *)
          (*   | _ -> txt   in *)
          let txt =
            match brother with
            | DeadEnd | LocAct (_, _) -> txt
            | Node _ -> txt ^ " or " ^ name_of_tree_failed entry brother  in
          txt
      | Some (tokl, _, _) ->
          List.fold_left
            (fun s tok ->
              ((if s = "" then "" else s ^ " then ") ^
               (match tok with
               | `Token (_, _,descr) ->  descr
               | `Keyword kwd -> kwd))) "" tokl 
      end
  | DeadEnd | LocAct (_, _) -> "???" 

let magic _s x = (* debug magic "Obj.magic: %s@." _s in *) Obj.magic x

(* [prev_symb_result] is cast by [Obj.magic] *)
let tree_failed ?(verbose=false) entry prev_symb_result prev_symb tree =
  let txt = name_of_tree_failed entry tree in
  let txt =
    match prev_symb with
    | `List0 s ->
        let txt1 = name_of_symbol_failed entry s in
        txt1 ^ " or " ^ txt ^ " expected"
    | `List1 s ->
        let txt1 = name_of_symbol_failed entry s in
        txt1 ^ " or " ^ txt ^ " expected"
    | `List0sep (s, sep) ->
        begin match magic "tree_failed: 'a -> 'b list" prev_symb_result with
        | [] ->
            let txt1 = name_of_symbol_failed entry s in
            txt1 ^ " or " ^ txt ^ " expected"
        | _ ->
            let txt1 = name_of_symbol_failed entry sep in
            txt1 ^ " or " ^ txt ^ " expected"
        end
    | `List1sep (s, sep) ->
        begin match magic "tree_failed: 'a -> 'b list" prev_symb_result with
        | [] ->
            let txt1 = name_of_symbol_failed entry s in
            txt1 ^ " or " ^ txt ^ " expected"
        | _ ->
            let txt1 = name_of_symbol_failed entry sep in
            txt1 ^ " or " ^ txt ^ " expected"
        end
    | `Try _ | `Peek _ (*NP: not sure about this*) (* | `Opt _ *)  -> txt ^ " expected"
    | _ -> txt ^ " expected after " ^ name_of_symbol entry prev_symb  in
  begin
    (* it may not necessary fail when  we use try somewhere*)
    if verbose then
      let tree = tree_in_entry prev_symb tree entry.desc in
      pp err_formatter
        ("@[<v 0>@,----------------------------------@,"^^
         "Parse error in entry [%s], rule:@;<0 2>@[%a@]@," ^^
         "----------------------------------@,@]@.")
        entry.name
        (Gprint.text#rules ) (Gstru.flatten_tree tree);
    else ();
    txt ^ " (in [" ^ entry.name ^ "])"
  end
    
let symb_failed entry prev_symb_result prev_symb symb =
  let tree = Node {node = symb; brother = DeadEnd; son = DeadEnd} in
  tree_failed entry prev_symb_result prev_symb tree

let symb_failed_txt e s1 s2 =
  symb_failed e 0 s1 s2



(* local variables: *)
(* compile-command: "pmake gfailed.cmo" *)
(* end: *)
