module SK = Datastructures.Liststack
module VariableMem = Variablemem.VariableMem

type aval = Apronext.Texprext.t (*this has to b*)
type constr = Apronext.Tconsext.t (*this has to b*)

type operand =
  (*i need a funcref operand type i think*)
  | BooleanExpression of constr
  | Expression of aval
  | LVarRef of VariableMem.binding
  | GVarRef of VariableMem.binding
  | FuncRef of Wasm.Types.ref_type * int32 option * int32 option
  | Label of Label.label

(*| Label*)
type stack = operand list
type t = stack
type varmemories = VariableMem.t

let print_stack s =
  Printf.printf "[";
  List.iter
    (fun x ->
      match x with
      | BooleanExpression _ -> Printf.printf "Boolex;"
      | Expression e ->
          Printf.printf "Expr:";
          Apronext.Texprext.print Format.std_formatter e;
          Printf.printf ";"
      | LVarRef _ -> Printf.printf "LVarRef;"
      | GVarRef _ -> Printf.printf "GVarRef;"
      | FuncRef _ -> Printf.printf "FuncRef;"
      | Label _ -> Printf.printf "label")
    s;
  Printf.printf "]\n"

let empty : stack = []
let peek_n = SK.peek_n
let pop_n = SK.pop_n
let pop = function _ :: t -> t | [] -> failwith "empty"
let push (x, s) = x :: s
let append sp s = sp @ s
let push_ops = append

let lsk s =
  List.filter
    (fun x -> match x with Label _ -> true | _ -> false)
    s

let peek_nth_label s nth = List.nth_opt (lsk s) nth

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

let concretize_assignment (s : stack) (mem : varmemories) (ref : operand) =
  let repl operand to_replace =
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
  in
  List.map (fun x -> repl x ref) s

let concretize_ret (s : stack) (mem : varmemories) =
  let global_bs =
    VariableMem.M.bindings mem.glob |> List.map (fun x -> GVarRef (fst x))
  in
  let rec concretize_gref stack gbindings =
    match gbindings with
    | [] -> stack
    | h :: t ->
        let stack' = concretize_assignment stack mem h in
        concretize_gref stack' t
  in
  concretize_gref s global_bs

let ival_join i1 i2 : Apronext.Intervalext.t = Apronext.Intervalext.join i1 i2

let ival_widen (smaller : Apron.Interval.t) (bigger : Apron.Interval.t) =
  if not (Apron.Interval.is_leq smaller bigger) then ival_join smaller bigger
  else
    let (smaller_l, smaller_u), (bigger_l, bigger_u) =
      ((smaller.inf, smaller.sup), (bigger.inf, bigger.sup))
    in
    let lower' =
      if bigger_l < smaller_l then Apron.Scalar.of_infty (-1) else bigger_l
    in
    let upper' =
      if bigger_u > smaller_u then Apron.Scalar.of_infty 1 else bigger_u
    in
    Apron.Interval.of_scalar lower' upper'

let ival_leq = Apronext.Intervalext.is_leq
let ival_eq = Apronext.Intervalext.equal

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

let join (m1, s1) (m2, s2) =
  (*two memories are needed, one for locals and one for globals*)
  Printf.printf "Joining: %i, %i\n" (List.length s1) (List.length s2);
  List.map2 (fun x y -> jw_operand (m1, x) (m2, y) ival_join) s1 s2

let widen (m1, s1) (m2, s2) =
  (*two memories are needed, one for locals and one for globals*)
  List.map2 (fun x y -> jw_operand (m1, x) (m2, y) ival_widen) s1 s2

let leq_operand m1 (o1 : operand) m2 (o2 : operand) =
  ival_leq (concretize m1 o1) (concretize m2 o2)

let eq_operand m1 (o1 : operand) m2 (o2 : operand) =
  ival_eq (concretize m1 o1) (concretize m2 o2)

let leq (m1, s1) (m2, s2) =
  VariableMem.leq m1 m2
  && List.for_all2 (fun fst snd -> leq_operand m1 fst m2 snd) s1 s2

let eq (m1, s1) (m2, s2) =
  VariableMem.eq m1 m2
  && List.for_all2 (fun fst snd -> eq_operand m1 fst m2 snd) s1 s2

let le os1 os2 = leq os1 os2 && not (eq os1 os2)

let unop s f =
  let operand, s = (peek_n 1 s |> List.hd, pop_n 1 s) in
  let res = f operand in
  (res, s)

let binop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 1, List.nth operand 0) in
  let res = f l r in
  (res, s)

let cmpop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 1, List.nth operand 0) in
  let res = f l r in
  (res, s)
