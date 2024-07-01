module SK = Datastructures.Liststack
module VariableMem = Variablememory

type aval = Apronext.Texprext.t (*this has to b*)

type operand =
  | Expression of aval
  | LVarRef of VariableMem.binding
  | GVarRef of VariableMem.binding

(*| Label*)
type stack = operand list
type t = stack
type varmemories = VariableMem.t

let empty : stack = []
let peek_n = SK.peek_n
let pop_n = SK.pop_n
let pop = function _ :: t -> t | [] -> failwith "empty"
let push x s = x :: s
let append sp s = sp @ s
let push_ops = append

let const_expr (mem : varmemories) inter =
  Apronext.Texprext.cst mem.ad.env (Apronext.Coeffext.Interval inter)

let var_expr (mem : varmemories) inter = Apronext.Texprext.var mem.ad.env inter

let ref_to_apronvar op =
  match op with
  | LVarRef i -> VariableMem.apronvar_of_binding i VariableMem.Loc
  | GVarRef i -> VariableMem.apronvar_of_binding i VariableMem.Glob
  | Expression _ -> failwith ""

let operand_to_expr (mem : varmemories) op =
  match op with
  | Expression a -> a
  | LVarRef i ->
      VariableMem.apronvar_of_binding i VariableMem.Loc |> var_expr mem
  | GVarRef i ->
      VariableMem.apronvar_of_binding i VariableMem.Glob |> var_expr mem

let concretize (mem : varmemories) op =
  match op with
  | Expression a -> Apronext.Abstractext.bound_texpr Apronext.Apol.man mem.ad a
  | LVarRef i -> VariableMem.lookup mem i VariableMem.Loc
  | GVarRef i -> VariableMem.lookup mem i VariableMem.Glob

let concretize_in_exp (mem : varmemories) op =
  concretize mem op |> const_expr mem

let replace (s : stack) (op : operand) exp =
  List.map (fun x -> if x = op then exp else op) s

let rec replace_var_in_exp destr (ref : operand) (mem : varmemories) =
  match destr with
  | Apronext.Texprext.Cst _ -> destr
  | Var var ->
      let av_ref = ref_to_apronvar ref in
      if av_ref = var then failwith "" else destr
  | Unop (_op, _e, _t, _r) -> Unop (_op, replace_var_in_exp _e ref mem, _t, _r)
  | Binop (_op, _el, _er, _t, _r) ->
      Binop
        ( _op,
          replace_var_in_exp _el ref mem,
          replace_var_in_exp _er ref mem,
          _t,
          _r )

let concretize_assignment (s : stack) (mem : varmemories) ref =
  match ref with
  | Expression exp ->
      let v =
        Apronext.Texprext.of_expr mem.ad.env
          (replace_var_in_exp (Apronext.Texprext.to_expr exp) ref mem)
      in
      replace s ref (Expression v)
  | LVarRef _ | GVarRef _ ->
      let v_expr = concretize_in_exp mem ref in
      replace s ref (Expression v_expr)

let ival_join i1 i2 : Apronext.Intervalext.t = Apronext.Intervalext.join i1 i2

let ival_widen i1 i2 =
  Apronext.Intervalext.join i1 i2 (*to be replaced with widening*)

let ival_leq = Apronext.Intervalext.is_leq
let ival_eq = Apronext.Intervalext.equal

let jw_operand (mem1, o1) (mem2, o2) operation =
  (*two memories are needed, one for locals and one for globals*)
  if o1 = o2 then o1
  else
    Expression
      (const_expr mem1 (operation (concretize mem1 o1) (concretize mem2 o2)))

let join (m1, s1) (m2, s2) =
  (*two memories are needed, one for locals and one for globals*)
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
  let operand, s = (peek_n 1 s, pop_n 1 s) in
  let operand = List.nth operand 0 in
  let res = f operand in
  push_ops [ res ] s

let binop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 0, List.nth operand 1) in
  let res = f l r in
  push_ops [ res ] s
