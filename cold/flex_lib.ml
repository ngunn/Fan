let clear_stack = Lexing_util.clear_stack
let lexing_store = Lexing_util.lexing_store
let fprintf = Format.fprintf
let std_formatter = Format.std_formatter
let from_string { FLoc.loc_start = loc_start;_} str =
  let () = clear_stack () in
  let lb = Lexing.from_string str in
  lb.lex_abs_pos <- loc_start.pos_cnum;
  lb.lex_curr_p <- loc_start;
  Fan_lex.from_lexbuf lb
let from_stream { FLoc.loc_start = loc_start;_} strm =
  let () = clear_stack () in
  let lb = Lexing.from_function (lexing_store strm) in
  lb.lex_abs_pos <- loc_start.pos_cnum;
  lb.lex_curr_p <- loc_start;
  Fan_lex.from_lexbuf lb
let rec clean (__strm : _ XStream.t) =
  match XStream.peek __strm with
  | Some (`EOI,loc) ->
      (XStream.junk __strm; XStream.lsing (fun _  -> (`EOI, loc)))
  | Some x ->
      (XStream.junk __strm;
       (let xs = __strm in
        XStream.icons x (XStream.slazy (fun _  -> clean xs))))
  | _ -> XStream.sempty
let rec strict_clean (__strm : _ XStream.t) =
  match XStream.peek __strm with
  | Some (`EOI,_) -> (XStream.junk __strm; XStream.sempty)
  | Some x ->
      (XStream.junk __strm;
       (let xs = __strm in
        XStream.icons x (XStream.slazy (fun _  -> strict_clean xs))))
  | _ -> XStream.sempty
let debug_from_string str =
  let loc = FLoc.string_loc in
  let stream = from_string loc str in
  (stream |> clean) |>
    (XStream.iter
       (fun (t,loc)  ->
          fprintf std_formatter "%a@;%a@\n" Ftoken.print t FLoc.print loc))
let list_of_string ?(verbose= true)  str =
  let result = ref [] in
  let loc = FLoc.string_loc in
  let stream = from_string loc str in
  (stream |> clean) |>
    (XStream.iter
       (fun (t,loc)  ->
          result := ((t, loc) :: (result.contents));
          if verbose
          then
            fprintf std_formatter "%a@;%a@\n" Ftoken.print t FLoc.print loc));
  List.rev result.contents
let get_tokens s = List.map fst (list_of_string ~verbose:false s)
let debug_from_file file =
  let loc = FLoc.mk file in
  let chan = open_in file in
  let stream = XStream.of_channel chan in
  ((from_stream loc stream) |> clean) |>
    (XStream.iter
       (fun (t,loc)  ->
          fprintf std_formatter "%a@;%a@\n" Ftoken.print t FLoc.print loc))