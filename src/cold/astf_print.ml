open Astf
module type S = sig val pp_print_loc : Locf.t Formatf.t end
module Make(U:S) =
  struct
    open U
    let pp_print_ant: Format.formatter -> ant -> unit =
      fun fmt  (`Ant (_a0,_a1))  ->
        Format.fprintf fmt "@[<1>(`Ant@ %a@ %a)@]" pp_print_loc _a0
          Tokenf.pp_print_ant _a1
    let pp_print_literal: Format.formatter -> literal -> unit =
      fun fmt  ->
        function
        | `Chr (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Chr@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Int (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Int@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Int32 (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Int32@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Int64 (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Int64@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Flo (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Flo@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Nativeint (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Nativeint@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Str (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Str@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Bool (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Bool@ %a@ %a)@]" pp_print_loc _a0
              Format.pp_print_bool _a1
        | `Unit _a0 ->
            Format.fprintf fmt "@[<1>(`Unit@ %a)@]" pp_print_loc _a0
    let pp_print_flag: Format.formatter -> flag -> unit =
      fun fmt  ->
        function
        | `Positive _a0 ->
            Format.fprintf fmt "@[<1>(`Positive@ %a)@]" pp_print_loc _a0
        | `Negative _a0 ->
            Format.fprintf fmt "@[<1>(`Negative@ %a)@]" pp_print_loc _a0
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let pp_print_position_flag: Format.formatter -> position_flag -> unit =
      fun fmt  ->
        function
        | `Positive _a0 ->
            Format.fprintf fmt "@[<1>(`Positive@ %a)@]" pp_print_loc _a0
        | `Negative _a0 ->
            Format.fprintf fmt "@[<1>(`Negative@ %a)@]" pp_print_loc _a0
        | `Normal _a0 ->
            Format.fprintf fmt "@[<1>(`Normal@ %a)@]" pp_print_loc _a0
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let rec pp_print_strings: Format.formatter -> strings -> unit =
      fun fmt  ->
        function
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_strings _a1 pp_print_strings _a2
        | `Str (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Str@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let pp_print_lident: Format.formatter -> lident -> unit =
      fun fmt  (`Lid (_a0,_a1))  ->
        Format.fprintf fmt "@[<1>(`Lid@ %a@ %a)@]" pp_print_loc _a0
          (fun fmt  -> Format.fprintf fmt "%S") _a1
    let pp_print_alident: Format.formatter -> alident -> unit =
      fun fmt  ->
        function
        | `Lid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let pp_print_auident: Format.formatter -> auident -> unit =
      fun fmt  ->
        function
        | `Uid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Uid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let pp_print_aident: Format.formatter -> aident -> unit =
      fun fmt  ->
        function
        | #alident as _a0 -> (pp_print_alident fmt _a0 :>unit)
        | #auident as _a0 -> (pp_print_auident fmt _a0 :>unit)
    let pp_print_astring: Format.formatter -> astring -> unit =
      fun fmt  ->
        function
        | `C (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`C@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let rec pp_print_uident: Format.formatter -> uident -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_uident _a1 pp_print_uident _a2
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_uident _a1 pp_print_uident _a2
        | #auident as _a0 -> (pp_print_auident fmt _a0 :>unit)
    let rec pp_print_ident: Format.formatter -> ident -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1 pp_print_ident _a2
        | `Apply (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Apply@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1 pp_print_ident _a2
        | #alident as _a0 -> (pp_print_alident fmt _a0 :>unit)
        | #auident as _a0 -> (pp_print_auident fmt _a0 :>unit)
    let pp_print_ident': Format.formatter -> ident' -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1 pp_print_ident _a2
        | `Apply (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Apply@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1 pp_print_ident _a2
        | `Lid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Uid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Uid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
    let rec pp_print_vid: Format.formatter -> vid -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_vid _a1 pp_print_vid _a2
        | `Lid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Uid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Uid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let pp_print_vid': Format.formatter -> vid' -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_vid _a1 pp_print_vid _a2
        | `Lid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Uid (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Uid@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
    let rec pp_print_dupath: Format.formatter -> dupath -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_dupath _a1 pp_print_dupath _a2
        | #auident as _a0 -> (pp_print_auident fmt _a0 :>unit)
    let pp_print_dlpath: Format.formatter -> dlpath -> unit =
      fun fmt  ->
        function
        | `Dot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Dot@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_dupath _a1 pp_print_alident _a2
        | #alident as _a0 -> (pp_print_alident fmt _a0 :>unit)
    let pp_print_any: Format.formatter -> any -> unit =
      fun fmt  (`Any _a0)  ->
        Format.fprintf fmt "@[<1>(`Any@ %a)@]" pp_print_loc _a0
    let rec pp_print_ctyp: Format.formatter -> ctyp -> unit =
      fun fmt  ->
        function
        | `Alias (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Alias@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_alident _a2
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `Arrow (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Arrow@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `ClassPath (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ClassPath@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1
        | `Label (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Label@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1 pp_print_ctyp _a2
        | `OptLabl (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`OptLabl@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_alident _a1 pp_print_ctyp _a2
        | #ident' as _a0 -> (pp_print_ident' fmt _a0 :>unit)
        | `TyObj (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyObj@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_name_ctyp _a1 pp_print_flag _a2
        | `TyObjEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`TyObjEnd@ %a@ %a)@]" pp_print_loc _a0
              pp_print_flag _a1
        | `TyPol (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyPol@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `TyPolEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`TyPolEnd@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1
        | `TyTypePol (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyTypePol@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_ctyp _a1 pp_print_ctyp _a2
        | `Quote (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Quote@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1 pp_print_alident _a2
        | `QuoteAny (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`QuoteAny@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1
        | `Par (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Par@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1
        | `Sta (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sta@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `PolyEq (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`PolyEq@ %a@ %a)@]" pp_print_loc _a0
              pp_print_row_field _a1
        | `PolySup (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`PolySup@ %a@ %a)@]" pp_print_loc _a0
              pp_print_row_field _a1
        | `PolyInf (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`PolyInf@ %a@ %a)@]" pp_print_loc _a0
              pp_print_row_field _a1
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `PolyInfSup (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`PolyInfSup@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_row_field _a1 pp_print_tag_names _a2
        | `Package (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Package@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mtyp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_type_parameters: Format.formatter -> type_parameters -> unit
      =
      fun fmt  ->
        function
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_type_parameters _a1 pp_print_type_parameters _a2
        | `Ctyp (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Ctyp@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_row_field: Format.formatter -> row_field -> unit =
      fun fmt  ->
        function
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
        | `Bar (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Bar@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_row_field _a1 pp_print_row_field _a2
        | `TyVrn (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`TyVrn@ %a@ %a)@]" pp_print_loc _a0
              pp_print_astring _a1
        | `TyVrnOf (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyVrnOf@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_astring _a1 pp_print_ctyp _a2
        | `Ctyp (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Ctyp@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1
    and pp_print_tag_names: Format.formatter -> tag_names -> unit =
      fun fmt  ->
        function
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_tag_names _a1 pp_print_tag_names _a2
        | `TyVrn (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`TyVrn@ %a@ %a)@]" pp_print_loc _a0
              pp_print_astring _a1
    and pp_print_decl: Format.formatter -> decl -> unit =
      fun fmt  ->
        function
        | `TyDcl (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`TyDcl@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_opt_decl_params
              _a2 pp_print_type_info _a3 pp_print_opt_type_constr _a4
        | `TyAbstr (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`TyAbstr@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_opt_decl_params
              _a2 pp_print_opt_type_constr _a3
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_decl _a1 pp_print_decl _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_type_constr: Format.formatter -> type_constr -> unit =
      fun fmt  ->
        function
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_type_constr _a1 pp_print_type_constr _a2
        | `Eq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Eq@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_opt_type_constr: Format.formatter -> opt_type_constr -> unit
      =
      fun fmt  ->
        function
        | `Some (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Some@ %a@ %a)@]" pp_print_loc _a0
              pp_print_type_constr _a1
        | `None _a0 ->
            Format.fprintf fmt "@[<1>(`None@ %a)@]" pp_print_loc _a0
    and pp_print_decl_param: Format.formatter -> decl_param -> unit =
      fun fmt  ->
        function
        | `Quote (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Quote@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1 pp_print_alident _a2
        | `QuoteAny (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`QuoteAny@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1
        | `Any _a0 -> Format.fprintf fmt "@[<1>(`Any@ %a)@]" pp_print_loc _a0
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_decl_params: Format.formatter -> decl_params -> unit =
      fun fmt  ->
        function
        | `Quote (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Quote@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1 pp_print_alident _a2
        | `QuoteAny (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`QuoteAny@ %a@ %a)@]" pp_print_loc _a0
              pp_print_position_flag _a1
        | `Any _a0 -> Format.fprintf fmt "@[<1>(`Any@ %a)@]" pp_print_loc _a0
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_decl_params _a1 pp_print_decl_params _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_opt_decl_params: Format.formatter -> opt_decl_params -> unit
      =
      fun fmt  ->
        function
        | `Some (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Some@ %a@ %a)@]" pp_print_loc _a0
              pp_print_decl_params _a1
        | `None _a0 ->
            Format.fprintf fmt "@[<1>(`None@ %a)@]" pp_print_loc _a0
    and pp_print_type_info: Format.formatter -> type_info -> unit =
      fun fmt  ->
        function
        | `TyMan (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`TyMan@ %a@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_ctyp _a1 pp_print_flag _a2 pp_print_type_repr _a3
        | `TyRepr (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyRepr@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_flag _a1 pp_print_type_repr _a2
        | `TyEq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyEq@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_flag _a1 pp_print_ctyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_type_repr: Format.formatter -> type_repr -> unit =
      fun fmt  ->
        function
        | `Record (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Record@ %a@ %a)@]" pp_print_loc _a0
              pp_print_name_ctyp _a1
        | `Sum (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Sum@ %a@ %a)@]" pp_print_loc _a0
              pp_print_or_ctyp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_name_ctyp: Format.formatter -> name_ctyp -> unit =
      fun fmt  ->
        function
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_name_ctyp _a1 pp_print_name_ctyp _a2
        | `RecCol (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`RecCol@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_ctyp _a2
              pp_print_flag _a3
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_or_ctyp: Format.formatter -> or_ctyp -> unit =
      fun fmt  ->
        function
        | `Bar (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Bar@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_or_ctyp _a1 pp_print_or_ctyp _a2
        | `TyCol (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TyCol@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_auident _a1 pp_print_ctyp _a2
        | `Of (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Of@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_auident _a1 pp_print_ctyp _a2
        | #auident as _a0 -> (pp_print_auident fmt _a0 :>unit)
    and pp_print_of_ctyp: Format.formatter -> of_ctyp -> unit =
      fun fmt  ->
        function
        | `Of (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Of@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_vid _a1 pp_print_ctyp _a2
        | #vid' as _a0 -> (pp_print_vid' fmt _a0 :>unit)
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_pat: Format.formatter -> pat -> unit =
      fun fmt  ->
        function
        | #vid as _a0 -> (pp_print_vid fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_pat _a2
        | `Vrn (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Vrn@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_pat _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_pat _a2
        | `Par (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Par@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | `Record (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Record@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_pat _a1
        | #literal as _a0 -> (pp_print_literal fmt _a0 :>unit)
        | `Alias (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Alias@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_alident _a2
        | `ArrayEmpty _a0 ->
            Format.fprintf fmt "@[<1>(`ArrayEmpty@ %a)@]" pp_print_loc _a0
        | `Array (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Array@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1
        | `LabelS (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`LabelS@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1
        | `Label (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Label@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1 pp_print_pat _a2
        | `OptLabl (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`OptLabl@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_alident _a1 pp_print_pat _a2
        | `OptLablS (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`OptLablS@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1
        | `OptLablExpr (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`OptLablExpr@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_pat _a2
              pp_print_exp _a3
        | `Bar (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Bar@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_pat _a2
        | `PaRng (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`PaRng@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_pat _a2
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_pat _a1 pp_print_ctyp _a2
        | `ClassPath (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ClassPath@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1
        | `Lazy (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lazy@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1
        | `ModuleUnpack (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ModuleUnpack@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_auident _a1
        | `ModuleConstraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ModuleConstraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_ctyp _a2
    and pp_print_rec_pat: Format.formatter -> rec_pat -> unit =
      fun fmt  ->
        function
        | `RecBind (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`RecBind@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_vid _a1 pp_print_pat _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_pat _a1 pp_print_rec_pat _a2
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_exp: Format.formatter -> exp -> unit =
      fun fmt  ->
        function
        | #vid as _a0 -> (pp_print_vid fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_exp _a2
        | `Vrn (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Vrn@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_exp _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_exp _a2
        | `Par (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Par@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | `Record (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Record@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_exp _a1
        | #literal as _a0 -> (pp_print_literal fmt _a0 :>unit)
        | `RecordWith (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`RecordWith@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_rec_exp _a1 pp_print_exp _a2
        | `Field (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Field@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_vid _a2
        | `ArrayDot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ArrayDot@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1 pp_print_exp _a2
        | `ArrayEmpty _a0 ->
            Format.fprintf fmt "@[<1>(`ArrayEmpty@ %a)@]" pp_print_loc _a0
        | `Array (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Array@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | `Assert (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Assert@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | `Assign (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Assign@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1 pp_print_exp _a2
        | `For (_a0,_a1,_a2,_a3,_a4,_a5) ->
            Format.fprintf fmt "@[<1>(`For@ %a@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_exp _a2
              pp_print_exp _a3 pp_print_flag _a4 pp_print_exp _a5
        | `Fun (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Fun@ %a@ %a)@]" pp_print_loc _a0
              pp_print_case _a1
        | `IfThenElse (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`IfThenElse@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_exp _a1 pp_print_exp _a2 pp_print_exp
              _a3
        | `IfThen (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`IfThen@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1 pp_print_exp _a2
        | `LabelS (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`LabelS@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1
        | `Label (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Label@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1 pp_print_exp _a2
        | `Lazy (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Lazy@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | `LetIn (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`LetIn@ %a@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_flag _a1 pp_print_bind _a2 pp_print_exp _a3
        | `LetTryInWith (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`LetTryInWith@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_bind _a2
              pp_print_exp _a3 pp_print_case _a4
        | `LetModule (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`LetModule@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mexp _a2
              pp_print_exp _a3
        | `Match (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Match@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_case _a2
        | `New (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`New@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ident _a1
        | `Obj (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Obj@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clfield _a1
        | `ObjEnd _a0 ->
            Format.fprintf fmt "@[<1>(`ObjEnd@ %a)@]" pp_print_loc _a0
        | `ObjPat (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ObjPat@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_pat _a1 pp_print_clfield _a2
        | `ObjPatEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ObjPatEnd@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1
        | `OptLabl (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`OptLabl@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_alident _a1 pp_print_exp _a2
        | `OptLablS (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`OptLablS@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1
        | `OvrInst (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`OvrInst@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_exp _a1
        | `OvrInstEmpty _a0 ->
            Format.fprintf fmt "@[<1>(`OvrInstEmpty@ %a)@]" pp_print_loc _a0
        | `Seq (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Seq@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | `Send (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Send@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_alident _a2
        | `StringDot (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`StringDot@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1 pp_print_exp _a2
        | `Try (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Try@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_case _a2
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_exp _a1 pp_print_ctyp _a2
        | `Coercion (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`Coercion@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_exp _a1 pp_print_ctyp _a2
              pp_print_ctyp _a3
        | `Subtype (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Subtype@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1 pp_print_ctyp _a2
        | `While (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`While@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1 pp_print_exp _a2
        | `LetOpen (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`LetOpen@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_ident _a2
              pp_print_exp _a3
        | `LocalTypeFun (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`LocalTypeFun@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_exp _a2
        | `Package_exp (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Package_exp@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_mexp _a1
    and pp_print_rec_exp: Format.formatter -> rec_exp -> unit =
      fun fmt  ->
        function
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_exp _a1 pp_print_rec_exp _a2
        | `RecBind (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`RecBind@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_vid _a1 pp_print_exp _a2
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_mtyp: Format.formatter -> mtyp -> unit =
      fun fmt  ->
        function
        | #ident' as _a0 -> (pp_print_ident' fmt _a0 :>unit)
        | `Sig (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Sig@ %a@ %a)@]" pp_print_loc _a0
              pp_print_sigi _a1
        | `SigEnd _a0 ->
            Format.fprintf fmt "@[<1>(`SigEnd@ %a)@]" pp_print_loc _a0
        | `Functor (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`Functor@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
              pp_print_mtyp _a3
        | `With (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`With@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mtyp _a1 pp_print_constr _a2
        | `ModuleTypeOf (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ModuleTypeOf@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_mexp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_sigi: Format.formatter -> sigi -> unit =
      fun fmt  ->
        function
        | `Val (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Val@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_alident _a1 pp_print_ctyp _a2
        | `External (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`External@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_ctyp _a2
              pp_print_strings _a3
        | `Type (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Type@ %a@ %a)@]" pp_print_loc _a0
              pp_print_decl _a1
        | `Exception (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Exception@ %a@ %a)@]" pp_print_loc _a0
              pp_print_of_ctyp _a1
        | `Class (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Class@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cltdecl _a1
        | `ClassType (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ClassType@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cltdecl _a1
        | `Module (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Module@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_auident _a1 pp_print_mtyp _a2
        | `ModuleTypeEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ModuleTypeEnd@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_auident _a1
        | `ModuleType (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ModuleType@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_sigi _a1 pp_print_sigi _a2
        | `DirectiveSimple (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`DirectiveSimple@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1
        | `Directive (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Directive@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_alident _a1 pp_print_exp _a2
        | `Open (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Open@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_flag _a1 pp_print_ident _a2
        | `Include (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Include@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mtyp _a1
        | `RecModule (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`RecModule@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mbind _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_mbind: Format.formatter -> mbind -> unit =
      fun fmt  ->
        function
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mbind _a1 pp_print_mbind _a2
        | `ModuleBind (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`ModuleBind@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
              pp_print_mexp _a3
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_constr: Format.formatter -> constr -> unit =
      fun fmt  ->
        function
        | `TypeEq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TypeEq@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_ctyp _a1 pp_print_ctyp _a2
        | `ModuleEq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ModuleEq@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_ident _a1 pp_print_ident _a2
        | `TypeEqPriv (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TypeEqPriv@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_ctyp _a1 pp_print_ctyp _a2
        | `TypeSubst (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TypeSubst@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_ctyp _a1 pp_print_ctyp _a2
        | `ModuleSubst (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ModuleSubst@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_ident _a1 pp_print_ident _a2
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_constr _a1 pp_print_constr _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_bind: Format.formatter -> bind -> unit =
      fun fmt  ->
        function
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_bind _a1 pp_print_bind _a2
        | `Bind (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Bind@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_exp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_case: Format.formatter -> case -> unit =
      fun fmt  ->
        function
        | `Bar (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Bar@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_case _a1 pp_print_case _a2
        | `Case (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Case@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_exp _a2
        | `CaseWhen (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`CaseWhen@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_pat _a1 pp_print_exp _a2 pp_print_exp
              _a3
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_mexp: Format.formatter -> mexp -> unit =
      fun fmt  ->
        function
        | #vid' as _a0 -> (pp_print_vid' fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mexp _a1 pp_print_mexp _a2
        | `Functor (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`Functor@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
              pp_print_mexp _a3
        | `Struct (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Struct@ %a@ %a)@]" pp_print_loc _a0
              pp_print_stru _a1
        | `StructEnd _a0 ->
            Format.fprintf fmt "@[<1>(`StructEnd@ %a)@]" pp_print_loc _a0
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_mexp _a1 pp_print_mtyp _a2
        | `PackageModule (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`PackageModule@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_stru: Format.formatter -> stru -> unit =
      fun fmt  ->
        function
        | `Class (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Class@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cldecl _a1
        | `ClassType (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ClassType@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cltdecl _a1
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_stru _a1 pp_print_stru _a2
        | `DirectiveSimple (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`DirectiveSimple@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1
        | `Directive (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Directive@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_alident _a1 pp_print_exp _a2
        | `Exception (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Exception@ %a@ %a)@]" pp_print_loc _a0
              pp_print_of_ctyp _a1
        | `StExp (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`StExp@ %a@ %a)@]" pp_print_loc _a0
              pp_print_exp _a1
        | `External (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`External@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_ctyp _a2
              pp_print_strings _a3
        | `Include (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Include@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mexp _a1
        | `Module (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Module@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_auident _a1 pp_print_mexp _a2
        | `RecModule (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`RecModule@ %a@ %a)@]" pp_print_loc _a0
              pp_print_mbind _a1
        | `ModuleType (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ModuleType@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_auident _a1 pp_print_mtyp _a2
        | `Open (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Open@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_flag _a1 pp_print_ident _a2
        | `Type (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Type@ %a@ %a)@]" pp_print_loc _a0
              pp_print_decl _a1
        | `TypeWith (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`TypeWith@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_decl _a1 pp_print_strings _a2
        | `Value (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Value@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_flag _a1 pp_print_bind _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_cltdecl: Format.formatter -> cltdecl -> unit =
      fun fmt  ->
        function
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cltdecl _a1 pp_print_cltdecl _a2
        | `CtDecl (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`CtDecl@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_ident _a2
              pp_print_type_parameters _a3 pp_print_cltyp _a4
        | `CtDeclS (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`CtDeclS@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_ident _a2
              pp_print_cltyp _a3
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_cltyp: Format.formatter -> cltyp -> unit =
      fun fmt  ->
        function
        | #vid' as _a0 -> (pp_print_vid' fmt _a0 :>unit)
        | `ClApply (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ClApply@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_vid _a1 pp_print_type_parameters _a2
        | `CtFun (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`CtFun@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_cltyp _a2
        | `ObjTy (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ObjTy@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_clsigi _a2
        | `ObjTyEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ObjTyEnd@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1
        | `Obj (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Obj@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clsigi _a1
        | `ObjEnd _a0 ->
            Format.fprintf fmt "@[<1>(`ObjEnd@ %a)@]" pp_print_loc _a0
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cltyp _a1 pp_print_cltyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_clsigi: Format.formatter -> clsigi -> unit =
      fun fmt  ->
        function
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clsigi _a1 pp_print_clsigi _a2
        | `SigInherit (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`SigInherit@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_cltyp _a1
        | `CgVal (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`CgVal@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_flag _a3 pp_print_ctyp _a4
        | `Method (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`Method@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_ctyp _a3
        | `VirMeth (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`VirMeth@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_ctyp _a3
        | `Eq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Eq@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_cldecl: Format.formatter -> cldecl -> unit =
      fun fmt  ->
        function
        | `ClDecl (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`ClDecl@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_ident _a2
              pp_print_type_parameters _a3 pp_print_clexp _a4
        | `ClDeclS (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`ClDeclS@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_ident _a2
              pp_print_clexp _a3
        | `And (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`And@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_cldecl _a1 pp_print_cldecl _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_clexp: Format.formatter -> clexp -> unit =
      fun fmt  ->
        function
        | `CeApp (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`CeApp@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clexp _a1 pp_print_exp _a2
        | #vid' as _a0 -> (pp_print_vid' fmt _a0 :>unit)
        | `ClApply (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ClApply@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_vid _a1 pp_print_type_parameters _a2
        | `CeFun (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`CeFun@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1 pp_print_clexp _a2
        | `LetIn (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`LetIn@ %a@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_flag _a1 pp_print_bind _a2 pp_print_clexp _a3
        | `Obj (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Obj@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clfield _a1
        | `ObjEnd _a0 ->
            Format.fprintf fmt "@[<1>(`ObjEnd@ %a)@]" pp_print_loc _a0
        | `ObjPat (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`ObjPat@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_pat _a1 pp_print_clfield _a2
        | `ObjPatEnd (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`ObjPatEnd@ %a@ %a)@]" pp_print_loc _a0
              pp_print_pat _a1
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_clexp _a1 pp_print_cltyp _a2
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    and pp_print_clfield: Format.formatter -> clfield -> unit =
      fun fmt  ->
        function
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_clfield _a1 pp_print_clfield _a2
        | `Inherit (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Inherit@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_flag _a1 pp_print_clexp _a2
        | `InheritAs (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`InheritAs@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_flag _a1 pp_print_clexp _a2
              pp_print_alident _a3
        | `CrVal (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`CrVal@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_flag _a3 pp_print_exp _a4
        | `VirVal (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`VirVal@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_ctyp _a3
        | `CrMth (_a0,_a1,_a2,_a3,_a4,_a5) ->
            Format.fprintf fmt "@[<1>(`CrMth@ %a@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_flag _a3 pp_print_exp _a4 pp_print_ctyp _a5
        | `CrMthS (_a0,_a1,_a2,_a3,_a4) ->
            Format.fprintf fmt "@[<1>(`CrMthS@ %a@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_flag _a3 pp_print_exp _a4
        | `VirMeth (_a0,_a1,_a2,_a3) ->
            Format.fprintf fmt "@[<1>(`VirMeth@ %a@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_alident _a1 pp_print_flag _a2
              pp_print_ctyp _a3
        | `Eq (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Eq@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ctyp _a1 pp_print_ctyp _a2
        | `Initializer (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Initializer@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_exp _a1
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let rec pp_print_ep: Format.formatter -> ep -> unit =
      fun fmt  ->
        function
        | #vid as _a0 -> (pp_print_vid fmt _a0 :>unit)
        | `App (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`App@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ep _a1 pp_print_ep _a2
        | `Vrn (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Vrn@ %a@ %a)@]" pp_print_loc _a0
              (fun fmt  -> Format.fprintf fmt "%S") _a1
        | `Com (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Com@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ep _a1 pp_print_ep _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ep _a1 pp_print_ep _a2
        | `Par (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Par@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ep _a1
        | `Constraint (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Constraint@ %a@ %a@ %a)@]"
              pp_print_loc _a0 pp_print_ep _a1 pp_print_ctyp _a2
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | `ArrayEmpty _a0 ->
            Format.fprintf fmt "@[<1>(`ArrayEmpty@ %a)@]" pp_print_loc _a0
        | `Array (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Array@ %a@ %a)@]" pp_print_loc _a0
              pp_print_ep _a1
        | `Record (_a0,_a1) ->
            Format.fprintf fmt "@[<1>(`Record@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_bind _a1
        | #literal as _a0 -> (pp_print_literal fmt _a0 :>unit)
    and pp_print_rec_bind: Format.formatter -> rec_bind -> unit =
      fun fmt  ->
        function
        | `RecBind (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`RecBind@ %a@ %a@ %a)@]" pp_print_loc
              _a0 pp_print_vid _a1 pp_print_ep _a2
        | `Sem (_a0,_a1,_a2) ->
            Format.fprintf fmt "@[<1>(`Sem@ %a@ %a@ %a)@]" pp_print_loc _a0
              pp_print_rec_bind _a1 pp_print_rec_bind _a2
        | #any as _a0 -> (pp_print_any fmt _a0 :>unit)
        | #ant as _a0 -> (pp_print_ant fmt _a0 :>unit)
    let dump_literal = Formatf.to_string pp_print_literal
    let dump_flag = Formatf.to_string pp_print_flag
    let dump_position_flag = Formatf.to_string pp_print_position_flag
    let dump_strings = Formatf.to_string pp_print_strings
    let dump_lident = Formatf.to_string pp_print_lident
    let dump_alident = Formatf.to_string pp_print_alident
    let dump_auident = Formatf.to_string pp_print_auident
    let dump_aident = Formatf.to_string pp_print_aident
    let dump_astring = Formatf.to_string pp_print_astring
    let dump_uident = Formatf.to_string pp_print_uident
    let dump_ident = Formatf.to_string pp_print_ident
    let dump_ident' = Formatf.to_string pp_print_ident'
    let dump_vid = Formatf.to_string pp_print_vid
    let dump_vid' = Formatf.to_string pp_print_vid'
    let dump_dupath = Formatf.to_string pp_print_dupath
    let dump_dlpath = Formatf.to_string pp_print_dlpath
    let dump_any = Formatf.to_string pp_print_any
    let dump_ctyp = Formatf.to_string pp_print_ctyp
    let dump_type_parameters = Formatf.to_string pp_print_type_parameters
    let dump_row_field = Formatf.to_string pp_print_row_field
    let dump_tag_names = Formatf.to_string pp_print_tag_names
    let dump_decl = Formatf.to_string pp_print_decl
    let dump_type_constr = Formatf.to_string pp_print_type_constr
    let dump_opt_type_constr = Formatf.to_string pp_print_opt_type_constr
    let dump_decl_param = Formatf.to_string pp_print_decl_param
    let dump_decl_params = Formatf.to_string pp_print_decl_params
    let dump_opt_decl_params = Formatf.to_string pp_print_opt_decl_params
    let dump_type_info = Formatf.to_string pp_print_type_info
    let dump_type_repr = Formatf.to_string pp_print_type_repr
    let dump_name_ctyp = Formatf.to_string pp_print_name_ctyp
    let dump_or_ctyp = Formatf.to_string pp_print_or_ctyp
    let dump_of_ctyp = Formatf.to_string pp_print_of_ctyp
    let dump_pat = Formatf.to_string pp_print_pat
    let dump_rec_pat = Formatf.to_string pp_print_rec_pat
    let dump_exp = Formatf.to_string pp_print_exp
    let dump_rec_exp = Formatf.to_string pp_print_rec_exp
    let dump_mtyp = Formatf.to_string pp_print_mtyp
    let dump_sigi = Formatf.to_string pp_print_sigi
    let dump_mbind = Formatf.to_string pp_print_mbind
    let dump_constr = Formatf.to_string pp_print_constr
    let dump_bind = Formatf.to_string pp_print_bind
    let dump_case = Formatf.to_string pp_print_case
    let dump_mexp = Formatf.to_string pp_print_mexp
    let dump_stru = Formatf.to_string pp_print_stru
    let dump_cltdecl = Formatf.to_string pp_print_cltdecl
    let dump_cltyp = Formatf.to_string pp_print_cltyp
    let dump_clsigi = Formatf.to_string pp_print_clsigi
    let dump_cldecl = Formatf.to_string pp_print_cldecl
    let dump_clexp = Formatf.to_string pp_print_clexp
    let dump_clfield = Formatf.to_string pp_print_clfield
    let dump_ep = Formatf.to_string pp_print_ep
    let dump_rec_bind = Formatf.to_string pp_print_rec_bind
  end
include Make(struct let pp_print_loc _ _ = () end)
let () =
  Ast2pt.dump_ident := dump_ident;
  Ast2pt.dump_ident := dump_ident;
  Ast2pt.dump_row_field := dump_row_field;
  Ast2pt.dump_name_ctyp := dump_name_ctyp;
  Ast2pt.dump_constr := dump_constr;
  Ast2pt.dump_mtyp := dump_mtyp;
  Ast2pt.dump_ctyp := dump_ctyp;
  Ast2pt.dump_or_ctyp := dump_or_ctyp;
  Ast2pt.dump_pat := dump_pat;
  Ast2pt.dump_type_parameters := dump_type_parameters;
  Ast2pt.dump_exp := dump_exp;
  Ast2pt.dump_case := dump_case;
  Ast2pt.dump_rec_exp := dump_rec_exp;
  Ast2pt.dump_type_constr := dump_type_constr;
  Ast2pt.dump_decl := dump_decl;
  Ast2pt.dump_sigi := dump_sigi;
  Ast2pt.dump_mbind := dump_mbind;
  Ast2pt.dump_mexp := dump_mexp;
  Ast2pt.dump_stru := dump_stru;
  Ast2pt.dump_cltyp := dump_cltyp;
  Ast2pt.dump_cldecl := dump_cldecl;
  Ast2pt.dump_cltdecl := dump_cltdecl;
  Ast2pt.dump_clsigi := dump_clsigi;
  Ast2pt.dump_clexp := dump_clexp;
  Ast2pt.dump_clfield := dump_clfield
