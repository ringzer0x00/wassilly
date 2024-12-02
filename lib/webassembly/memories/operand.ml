module VariableMem = Variablemem.VariableMem

let printer = Utilities.Printer.print

type aval = Apronext.Texprext.t (*this has to b*)
type constr = Apronext.Tconsext.t (*this has to b*)
type varmemories = VariableMem.t
type wasmNumeric = Wasm.Types.num_type

type operand =
  | BooleanExpression of constr
  | Expression of aval * wasmNumeric
  | LVarRef of VariableMem.binding * wasmNumeric
  | GVarRef of VariableMem.binding * wasmNumeric
  | FuncRef of Wasm.Types.ref_type * int32 option * int32 option
  | Label of Label.label
  | Bottom

let type_of_operand = function
  | Expression (_, wasmNumeric) -> wasmNumeric
  | LVarRef (_, wasmNumeric) -> wasmNumeric
  | GVarRef (_, wasmNumeric) -> wasmNumeric
  | BooleanExpression _ -> Wasm.Types.I32Type
  | Label _ -> failwith "labeeeeeeeeeeeel"
  | FuncRef _ -> failwith "funcref @ type of operand"
  | Bottom -> failwith "bottom asked for type"

let size_of_type = function
  | Wasm.Types.I32Type | Wasm.Types.F32Type -> 32
  | Wasm.Types.I64Type | Wasm.Types.F64Type -> 64

let print_operand = function
  | BooleanExpression c ->
      Format.print_string "Boolex:";
      Apronext.Tconsext.print Format.std_formatter c
  | Expression (e, _) ->
      Format.print_string "Expr:";
      Apronext.Texprext.print Format.std_formatter e
  | LVarRef (v, _) ->
      Format.print_string
        (Printf.sprintf "LVarRef:%s" (VariableMem.string_of_binding v))
  | GVarRef (v, _) ->
      Format.print_string
        (Printf.sprintf "GVarRef:%s" (VariableMem.string_of_binding v))
  | FuncRef _ -> Format.print_string "FuncRef;"
  | Label _ -> Format.print_string "label"
  | Bottom -> Format.print_string "bottom"

let is_label = function Label _ -> true | _ -> false

let const_expr (mem : varmemories) inter =
  Apronext.Texprext.cst mem.ad.env (Apronext.Coeffext.Interval inter)

let cast_expr ex t r = Apronext.Texprext.unop Apronext.Texprext.Cast ex t r
let max_val = function Wasm.Types.I32Type -> failwith "" | _ -> failwith ""
let var_expr (mem : varmemories) var = Apronext.Texprext.var mem.ad.env var

let ref_to_apronvar op =
  match op with
  | LVarRef (i, _) -> VariableMem.apronvar_of_binding i VariableMem.Loc
  | GVarRef (i, _) -> VariableMem.apronvar_of_binding i VariableMem.Glob
  | Expression _ -> Apron.Var.of_string "non-existing-variable"
  | BooleanExpression _ ->
      failwith "ref to apronvar @ operandstack - bexpr case"
  | FuncRef _ -> failwith "no correspondance of funcref here"
  | Label _ -> failwith "apronvar of label lmao"
  | Bottom -> failwith "bottom @ ref"

let ref_of_binding b gl =
  match gl with
  | VariableMem.Glob -> GVarRef (b, b.t)
  | VariableMem.Loc -> LVarRef (b, b.t)

let boole_as_int c (mem : varmemories) =
  let sat c = Apronext.Abstractext.sat_tcons Apronext.Apol.man mem.ad c in
  let sat_t, sat_f = (sat c, sat (Apronext.Tconsext.neg c)) in
  match (sat_t, sat_f) with
  | true, false -> Apronext.Intervalext.of_int 1 1
  | false, true -> Apronext.Intervalext.of_int 0 0
  | false, false -> Apronext.Intervalext.of_int 0 1
  | true, true -> failwith "wtf?????? @ operand_to_expr"

let boole_filter o (mem : varmemories) =
  match o with
  | BooleanExpression c ->
      let filter c =
        Apronext.Abstractext.filter_tcons Apronext.Apol.man mem.ad c
      in
      (filter c, filter (Apronext.Tconsext.neg c))
  | _ -> (mem.ad, mem.ad)

let operand_to_expr (mem : varmemories) op =
  match op with
  | Expression (a, _) -> a
  | LVarRef _ as r -> ref_to_apronvar r |> var_expr mem
  | GVarRef _ as r -> ref_to_apronvar r |> var_expr mem
  | BooleanExpression constr -> const_expr mem (boole_as_int constr mem)
  | FuncRef _ -> failwith "cannot convert funcref to expr"
  | Label _ -> failwith "cannot convert to expr label"
  | Bottom -> failwith "bottom has no expr"

let concretize (mem : varmemories) op =
  match op with
  | Expression (e, _) ->
      Apronext.Abstractext.bound_texpr Apronext.Apol.man mem.ad e
  | LVarRef (i, _) -> VariableMem.lookup mem i VariableMem.Loc
  | GVarRef (i, _) -> VariableMem.lookup mem i VariableMem.Glob
  | BooleanExpression c -> boole_as_int c mem
  | FuncRef _ -> failwith "idk @ concretize funcref"
  | Label _ -> failwith "cannot concretize label"
  | Bottom -> failwith "cannot conc bottom"

let operand_to_bits mem op =
  let _typ_ = type_of_operand op in
  let _interval = concretize mem op in
  let _size = size_of_type _typ_ in
  failwith ""

let concretize_in_exp (mem : varmemories) op =
  concretize mem op |> const_expr mem

let rec replace_var_in_exp destr (ref : operand) (mem : varmemories) =
  match destr with
  | Apronext.Texprext.Cst _ as d -> d
  | Var var as v ->
      let av_ref = ref_to_apronvar ref in
      if Apron.Var.compare av_ref var = 0 then
        Apronext.Texprext.Cst (Apronext.Coeffext.Interval (concretize mem ref))
      else v
  | Unop (_op, _e, _t, _r) -> Unop (_op, replace_var_in_exp _e ref mem, _t, _r)
  | Binop (_op, _el, _er, _t, _r) ->
      Binop
        ( _op,
          replace_var_in_exp _el ref mem,
          replace_var_in_exp _er ref mem,
          _t,
          _r )

let repl operand to_replace (mem : varmemories) =
  match operand with
  | Expression (exp, t) ->
      let v =
        Apronext.Texprext.of_expr mem.ad.env
          (replace_var_in_exp (Apronext.Texprext.to_expr exp) operand mem)
      in
      Expression (v, t)
  | LVarRef (_, t) as o ->
      printer Format.print_string "Concretize LVarRef\n";
      let v_expr = concretize_in_exp mem o in
      printer Format.print_string "LVarRef Concretized as:\n";
      printer (Apronext.Texprext.print Format.std_formatter) v_expr;
      if operand = to_replace then Expression (v_expr, t) else to_replace
  | GVarRef (_, t) as o ->
      printer Format.print_string "Concretize GVarRef\n";
      let v_expr = concretize_in_exp mem o in
      printer Format.print_string "GVarRef Concretized as:\n";
      printer (Apronext.Texprext.print Format.std_formatter) v_expr;
      if operand = to_replace then Expression (v_expr, t) else to_replace
  | BooleanExpression bex ->
      let exp = Apronext.Tconsext.get_texpr1 bex in
      let _v =
        Apronext.Texprext.of_expr mem.ad.env
          (replace_var_in_exp (Apronext.Texprext.to_expr exp) operand mem)
      in
      failwith "re-construct bex', analyse stuff in bex blabla"
  | FuncRef _ -> failwith "funcref @ concretize"
  | Label _ as l -> l
  | Bottom -> failwith "bottom @ operand to replace"

let convert_extend vm op dt =
  match op with
  | Expression (e, _) -> Expression (e, dt)
  | (LVarRef _ | GVarRef _) as r -> Expression (concretize_in_exp vm r, dt)
  | BooleanExpression _ as c -> Expression (concretize_in_exp vm c, dt)
  | _ -> failwith "operand conversion (extension)"

let demote ?(rnd = Apronext.Texprext.Zero) vm op dt =
  let i = concretize vm op in
  Expression (cast_expr (const_expr vm i) Apronext.Texprext.Single rnd, dt)

let round vm op rnd =
  let opt = type_of_operand op in
  let at =
    match opt with
    | Wasm.Types.I32Type | I64Type -> Apronext.Texprext.Int
    | F32Type -> Apronext.Texprext.Single
    | F64Type -> Apronext.Texprext.Double
  in
  let i = concretize vm op in
  Expression (cast_expr (const_expr vm i) at rnd, opt)

let jw_operand (mem1, o1) (mem2, o2) operation =
  (match (o1, o2) with
  | Label l1, Label l2 ->
      if l1 != l2 then (
        printer Format.print_string (Label.print_label l1);
        printer Format.print_string "\n";
        printer Format.print_string (Label.print_label l2))
  | _ -> ());
  if compare o1 o2 = 0 then o1
  else
    let t, _ = (type_of_operand o1, type_of_operand o2) in
    let a = concretize mem1 o1 in
    let b = concretize mem2 o2 in
    Expression (const_expr mem1 (operation a b), t)

let ival_leq = Apronext.Intervalext.is_leq
let ival_eq = Apronext.Intervalext.equal

let leq_operand m1 (o1 : operand) m2 (o2 : operand) =
  match (o1, o2) with
  | Label _, Label _ -> true (*prova*)
  | _ -> ival_leq (concretize m1 o1) (concretize m2 o2)

let eq_operand m1 (o1 : operand) m2 (o2 : operand) =
  match (o1, o2) with
  | Label _, Label _ -> o1 = o2 (*prova*)
  | _ -> ival_eq (concretize m1 o1) (concretize m2 o2)
