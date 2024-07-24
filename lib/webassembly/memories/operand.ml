module VariableMem = Variablemem.VariableMem

type aval = Apronext.Texprext.t (*this has to b*)
type constr = Apronext.Tconsext.t (*this has to b*)
type varmemories = VariableMem.t

type operand =
  | BooleanExpression of constr
  | Expression of aval
  | LVarRef of VariableMem.binding
  | GVarRef of VariableMem.binding
  | FuncRef of Wasm.Types.ref_type * int32 option * int32 option
  | Label of Label.label

let print_operand = function
  | BooleanExpression _ -> Printf.printf "Boolex;"
  | Expression e ->
      Printf.printf "Expr:";
      Apronext.Texprext.print Format.std_formatter e;
      Printf.printf ";"
  | LVarRef _ -> Printf.printf "LVarRef;"
  | GVarRef _ -> Printf.printf "GVarRef;"
  | FuncRef _ -> Printf.printf "FuncRef;"
  | Label _ -> Printf.printf "label"

let is_label = function Label _ -> true | _ -> false

let const_expr (mem : varmemories) inter =
  Apronext.Texprext.cst mem.ad.env (Apronext.Coeffext.Interval inter)

let var_expr (mem : varmemories) var = Apronext.Texprext.var mem.ad.env var

let ref_to_apronvar op =
  match op with
  | LVarRef i -> VariableMem.apronvar_of_binding i VariableMem.Loc
  | GVarRef i -> VariableMem.apronvar_of_binding i VariableMem.Glob
  | Expression _ -> failwith "ref to apronvar @ operandstack - expr case"
  | BooleanExpression _ ->
      failwith "ref to apronvar @ operandstack - bexpr case"
  | FuncRef _ -> failwith "no correspondance of funcref here"
  | Label _ -> failwith "apronvar of label lmao"

let ref_of_binding b gl =
  match gl with VariableMem.Glob -> GVarRef b | VariableMem.Loc -> LVarRef b

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
  | Expression a -> a
  | LVarRef _ as r -> ref_to_apronvar r |> var_expr mem
  | GVarRef _ as r -> ref_to_apronvar r |> var_expr mem
  | BooleanExpression constr -> const_expr mem (boole_as_int constr mem)
  | FuncRef _ -> failwith "cannot convert funcref to expr"
  | Label _ -> failwith "cannot convert to expr label"

let concretize (mem : varmemories) op =
  match op with
  | Expression e -> Apronext.Abstractext.bound_texpr Apronext.Apol.man mem.ad e
  | LVarRef i -> VariableMem.lookup mem i VariableMem.Loc
  | GVarRef i -> VariableMem.lookup mem i VariableMem.Glob
  | BooleanExpression c -> boole_as_int c mem
  | FuncRef _ -> failwith "idk @ concretize funcref"
  | Label _ -> failwith "cannot concretize label"

let concretize_in_exp (mem : varmemories) op =
  concretize mem op |> const_expr mem

let rec replace_var_in_exp destr (ref : operand) (mem : varmemories) =
  match destr with
  | Apronext.Texprext.Cst _ as d -> d
  | Var var as v ->
      let av_ref = ref_to_apronvar ref in
      if av_ref = var then
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
  | Expression exp ->
      let v =
        Apronext.Texprext.of_expr mem.ad.env
          (replace_var_in_exp (Apronext.Texprext.to_expr exp) operand mem)
      in
      Expression v
  | LVarRef _ as o ->
      Printf.printf "Concretize LVarRef\n";
      let v_expr = concretize_in_exp mem o in
      Printf.printf "LVarRef Concretized as:\n";
      Apronext.Texprext.print Format.std_formatter v_expr;
      if operand = to_replace then Expression v_expr else to_replace
  | GVarRef _ as o ->
      Printf.printf "Concretize GVarRef\n";
      let v_expr = concretize_in_exp mem o in
      if operand = to_replace then Expression v_expr else to_replace
  | BooleanExpression bex ->
      let exp = Apronext.Tconsext.get_texpr1 bex in
      let _v =
        Apronext.Texprext.of_expr mem.ad.env
          (replace_var_in_exp (Apronext.Texprext.to_expr exp) operand mem)
      in
      failwith "re-construct bex', analyse stuff in bex blabla"
  | FuncRef _ -> failwith "funcref @ concretize"
  | Label _ as l -> l

let jw_operand (mem1, o1) (mem2, o2) operation =
  (*two memories are needed, one for locals and one for globals*)
  if o1 = o2 then o1
  else
    let a = concretize mem1 o1 in
    let b = concretize mem2 o2 in
    Printf.printf "J/W operands:";
    Apron.Interval.print Format.std_formatter a;
    Printf.printf "\n";

    Apron.Interval.print Format.std_formatter b;
    Printf.printf "\n-----------------\n";

    Expression (const_expr mem1 (operation a b))

let ival_leq = Apronext.Intervalext.is_leq
let ival_eq = Apronext.Intervalext.equal

let leq_operand m1 (o1 : operand) m2 (o2 : operand) =
  ival_leq (concretize m1 o1) (concretize m2 o2)

let eq_operand m1 (o1 : operand) m2 (o2 : operand) =
  ival_eq (concretize m1 o1) (concretize m2 o2)
