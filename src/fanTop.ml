
open LibUtil

(** FIXME a better register mode *)
(* open Mktop;; *)
let (wrap,toplevel_phrase,use_file)  =
  Mktop.((wrap,  toplevel_phrase,use_file))
    
(* avoid dependency on [Parse] module  *)
let parse_toplevel_phrase_old = !Toploop.parse_toplevel_phrase;;
let use_file_old = !Toploop.parse_use_file ;;

let normal () = begin
  Toploop.parse_toplevel_phrase := parse_toplevel_phrase_old;
  Toploop.parse_use_file := use_file_old;
end
    
let fan ()  = begin
  Toploop.parse_toplevel_phrase :=
    wrap toplevel_phrase ~print_location:Toploop.print_location;
  Toploop.parse_use_file :=
    wrap use_file ~print_location:Toploop.print_location
end;;

begin
  Printexc.register_printer Mktop.normal_handler;
  Hashtbl.replace Toploop.directive_table "fan"
    (Toploop.Directive_none (fun () -> fan ()));
  Hashtbl.replace Toploop.directive_table "normal"
    (Toploop.Directive_none (fun () -> normal ()));

  Fsyntax.current_warning :=
    (fun loc txt ->
      Toploop.print_warning  loc Format.err_formatter
        (Warnings.Camlp4 txt));
  AstParsers.use_parsers ["revise";"stream"]
end;;


begin
  Topdirs.dir_install_printer
    Format.std_formatter
    (Longident.Ldot ((Longident.Lident "Fgram"),"dump"));
  fan ()
end;;





