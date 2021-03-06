let parse_file = Prelude.parse_file
let parse_interf = Prelude.parse_interf
let parse_implem = Prelude.parse_implem
let eprintf = Format.eprintf
let fprintf = Format.fprintf
let printf = Format.printf
open Util
let just_print_filters () =
  let pp = eprintf in
  let p_tbl f tbl = Hashtbl.iter (fun k  _v  -> fprintf f "%s@;" k) tbl in
  pp "@[for interface:@[<hv2>%a@]@]@." p_tbl Ast_filters.interf_filters;
  pp "@[for phrase:@[<hv2>%a@]@]@." p_tbl Ast_filters.implem_filters;
  pp "@[for top_phrase:@[<hv2>%a@]@]@." p_tbl Ast_filters.topphrase_filters
let just_print_parsers () =
  let pp = eprintf in
  let p_tbl f tbl = Hashtbl.iter (fun k  _v  -> fprintf f "%s@;" k) tbl in
  pp "@[Loaded Parsers:@;@[<hv2>%a@]@]@." p_tbl
    Ast_parsers.registered_parsers
let just_print_applied_parsers () =
  let pp = eprintf in
  pp "@[Applied Parsers:@;@[<hv2>%a@]@]@."
    (fun f  q  -> Queue.iter (fun (k,_)  -> fprintf f "%s@;" k) q)
    Ast_parsers.applied_parsers
type file_kind =  
  | Intf of string
  | Impl of string
  | Str of string
  | ModuleImpl of string
  | IncludeDir of string 
let print_loaded_modules = ref false
let output_file = ref None
let process_intf name =
  let v =
    (Option.map Ast_filters.apply_interf_filters) @@
      (parse_file name parse_interf) in
  Prelude.CurrentPrinter.print_interf ?input_file:(Some name)
    ?output_file:(!output_file) v
let process_impl name =
  let v =
    (Option.map Ast_filters.apply_implem_filters) @@
      (parse_file name parse_implem) in
  Prelude.CurrentPrinter.print_implem ~input_file:name
    ?output_file:(!output_file) v
let input_file x =
  match x with
  | Intf file_name ->
      (if file_name <> "-"
       then
         Configf.compilation_unit :=
           (Some
              (String.capitalize
                 (let open Filename in chop_extension (basename file_name))));
       Configf.current_input_file := file_name;
       process_intf file_name)
  | Impl file_name ->
      (if file_name <> "-"
       then
         Configf.compilation_unit :=
           (Some
              (String.capitalize
                 (let open Filename in chop_extension (basename file_name))));
       Configf.current_input_file := file_name;
       process_impl file_name)
  | Str s ->
      let (f,o) = Filename.open_temp_file "from_string" ".ml" in
      (output_string o s;
       close_out o;
       Configf.current_input_file := f;
       process_impl f;
       at_exit (fun ()  -> Sys.remove f))
  | ModuleImpl file_name -> Control_require.add file_name
  | IncludeDir dir -> Ref.modify Configf.dynload_dirs (cons dir)
let initial_spec_list: (string* Arg.spec* string) list =
  [("-I", (String ((fun x  -> input_file (IncludeDir x)))),
     "<directory>  Add directory in search patch for object files.");
  ("-intf", (String ((fun x  -> input_file (Intf x)))),
    "<file>  Parse <file> as an interface, whatever its extension.");
  ("-impl", (String ((fun x  -> input_file (Impl x)))),
    "<file>  Parse <file> as an implementation, whatever its extension.");
  ("-str", (String ((fun x  -> input_file (Str x)))),
    "<string>  Parse <string> as an implementation.");
  ("-o", (String ((fun x  -> output_file := (Some x)))),
    "<file> Output on <file> instead of standard output.");
  ("-list", (Unit Ast_quotation.dump_names_tbl), "list all registered DDSLs");
  ("-list_directive", (Unit Ast_quotation.dump_directives),
    "list all registered directives");
  ("-unsafe", (Set Configf.unsafe),
    "Generate unsafe accesses to array and strings.");
  ("-where",
    (Unit ((fun ()  -> print_endline Configf.fan_plugins_library; exit 0))),
    " Print location of standard library and exit");
  ("-loc", (Set_string Locf.name),
    ("<name>   Name of the location variable (default: " ^
       ((!Locf.name) ^ ").")));
  ("-v",
    (Unit ((fun ()  -> eprintf "Fan version %s@." Configf.version; exit 0))),
    "Print Fan version and exit.");
  ("-compilation-unit",
    (Unit
       ((fun ()  ->
           (match !Configf.compilation_unit with
            | Some v -> printf "%s@." v
            | None  -> printf "null");
           exit 0))), "Print the current compilation unit");
  ("-plugin", (String Control_require.add), "load plugin cma or cmxs files");
  ("-loaded-modules", (Set print_loaded_modules),
    "Print the list of loaded modules.");
  ("-loaded-filters", (Unit just_print_filters),
    "Print the registered filters.");
  ("-loaded-parsers", (Unit just_print_parsers), "Print the loaded parsers.");
  ("-used-parsers", (Unit just_print_applied_parsers),
    "Print the applied parsers.");
  ("-dlang",
    (String
       ((fun s  ->
           Ast_quotation.default :=
             (Ast_quotation.resolve_name { domain = (`Sub []); name = s })))),
    " Set the default language");
  ("-printer",
    (String
       ((fun s  ->
           let x =
             try Hashtbl.find Prelude.backends s
             with | Not_found  -> failwithf "%s backend not found" s in
           Prelude.sigi_printer := x.interf; Prelude.stru_printer := x.implem))),
    " Set the backend");
  ("-printers",
    (Unit
       ((fun _  ->
           Prelude.backends |>
             (Hashtbl.iter
                (fun k  (x : Prelude.backend)  ->
                   Format.eprintf "@[-printer %s, %s@]@\n" k x.descr))))),
    " List the backends available")]
let anon_fun name =
  let check = Filename.check_suffix name in
  input_file
    (if check ".mli"
     then Intf name
     else
       if check ".ml"
       then Impl name
       else
         if check Dyn_load.objext
         then ModuleImpl name
         else
           if check Dyn_load.libext
           then ModuleImpl name
           else raise (Arg.Bad ("don't know what to do with " ^ name)))
