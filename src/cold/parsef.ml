open Astf
let ep = Gramf.mk "ep"
let _ =
  Gramf.extend_single
    ({
       entry = (ep : 'ep Gramf.t );
       olevel =
         ({
            label = None;
            lassoc = true;
            productions =
              [{
                 symbols =
                   [Token
                      ({ descr = { tag = `Lid; word = Any; tag_name = "Lid" }
                       } : Tokenf.pattern )];
                 annot = "(`Lid (_loc, x) : Astf.ep )\n";
                 fn =
                   (Gramf.mk_action
                      (fun (__fan_0 : Tokenf.txt)  (_loc : Locf.t)  ->
                         let x = __fan_0.txt in
                         ((`Lid (_loc, x) : Astf.ep ) : 'ep ) : Tokenf.txt ->
                                                                  Locf.t ->
                                                                    'ep ))
               }]
          } : Gramf.olevel )
     } : _ Gramf.single_extend_statement )
let exp loc str = Gramlib.parse_string_eoi Syntaxf.exp ~loc str
let pat loc str = Gramlib.parse_string_eoi Syntaxf.pat ~loc str
let stru loc str = Gramlib.parse_string_eoi Syntaxf.stru ~loc str
let ep loc str = (Gramlib.parse_string_eoi ep ~loc str : ep )
let ident loc str = Gramlib.parse_string_eoi Syntaxf.ident ~loc str
let anti_filter = Ant.antiquot_expander ~parse_exp:exp ~parse_pat:pat
let exp_filter (x : ep) = anti_filter#exp (x :>exp)
let pat_filter (x : ep) = anti_filter#pat (x :>pat)
let anti_filter_n = Ant.expandern ~parse_exp:exp ~parse_pat:pat
let exp_filter_n (x : ep) = anti_filter_n#exp (x :>exp)
let pat_filter_n (x : ep) = anti_filter_n#pat (x :>pat)
let expand_exp (x : Tokenf.quot) =
  if x.name = Tokenf.empty_name
  then let expander loc _ s = exp loc s in Tokenf.quot_expand expander x
  else Ast_quotation.expand x Dyn_tag.exp
let expand_stru (x : Tokenf.quot) =
  if x.name = Tokenf.empty_name
  then let expander loc _ s = stru loc s in Tokenf.quot_expand expander x
  else Ast_quotation.expand x Dyn_tag.stru
