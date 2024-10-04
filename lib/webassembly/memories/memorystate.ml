module SK = Datastructures.Liststack
module VariableMem = Variablemem.VariableMem
open Datastructures.Monad.DefBot

type ms = {
  ops : Operandstack.t;
  var : VariableMem.t;
  mem : Linearmem.t;
  tab : Tables.t;
}

let ops ms = ms.ops
let var ms = ms.var
let mem ms = ms.mem
let tab ms = ms.tab

type 'a tt = 'a t
type t = ms tt

let peek = SK.peek
let peek_n = SK.peek_n
let pop = SK.pop
let pop_n = SK.pop_n

let lsk s =
  List.filter (fun x -> match x with Operand.Label _ -> true | _ -> false) s

let peek_nth_label s nth = List.nth_opt (lsk s) nth

(* update functions *)
let update_operandstack ops' (k : t) =
  k >>= fun a -> return { ops = ops'; var = a.var; mem = a.mem; tab = a.tab }

let update_tables tab' (k : t) =
  k >>= fun a -> return { ops = a.ops; var = a.var; mem = a.mem; tab = tab' }

let update_linearmem mem' (k : t) =
  k >>= fun a -> return { ops = a.ops; var = a.var; mem = mem'; tab = a.tab }

let update_varmem (var' : VariableMem.t) (k : t) =
  match Apronext.Abstractext.is_bottom Apronext.Apol.man var'.ad with
  | true -> Bot
  | false ->
      k >>= fun a ->
      return { ops = a.ops; var = var'; mem = a.mem; tab = a.tab }

(* pop functions *)
let pop_operand k : t = k >>= fun a -> update_operandstack (a.ops |> pop) k

let rec pop_n_labels _ms _n =
  _ms >>= fun a ->
  Printf.printf "popping";
  let n', sk' =
    match peek a.ops with Label _ -> (_n - 1, pop a.ops) | _ -> (_n, pop a.ops)
  in
  let ms' = update_operandstack sk' _ms in
  if n' = 0 then ms' else pop_n_labels ms' n'

let pop_n_operand n k : t =
  k >>= fun a -> update_operandstack (a.ops |> pop_n n) k

(* peek functions *)
let peek_n_operand n k = k >>=? fun a -> a.ops |> peek_n n
let peek_operand k = peek_n_operand 1 k
let peek_binop k = peek_n_operand 2 k
let peek_nth_label k n = k >>=? fun a -> peek_nth_label a.ops n

(* push functions *)
let push_operand x k = k >>= fun a -> update_operandstack (x @ a.ops) k

(*table stuff*)
let table_getrefs idx typ k =
  k >>=? fun a ->
  let table = List.nth a.tab 0 in
  Table.find_by_idx idx table |> Table.find_by_types typ

(*other*)
let concretize_operand o k = k >>=? fun a -> Operand.concretize_in_exp a.var o

let concretize_expr e k =
  k >>=? fun a -> Apronext.Abstractext.bound_texpr Apronext.Apol.man a.var.ad e

let operand_as_interval o k =
  let e = concretize_operand o k in
  concretize_expr e k

let bind_vars b gl (k : t) =
  k >>= fun a -> update_varmem (VariableMem.bind a.var b gl) k

let is_lsk_empty k =
  match k with
  | Bot -> failwith "lsk emptu @ frame"
  | Def kx -> ( match lsk kx.ops with [] -> true | _ -> false)

let write_mem_raw k _off _data =
  k >>= fun a ->
  return
    {
      ops = a.ops;
      var = a.var;
      tab = a.tab;
      mem = Linearmem.internal_write_byte_raw _data _off a.mem;
    }

let assign_var k gl b e =
  k >>= fun a ->
  return
    {
      ops =
        Operandstack.concretize_assignment a.ops a.var
          (Operand.ref_of_binding b gl);
      var = VariableMem.assign a.var gl b (Operand.operand_to_expr a.var e);
      tab = a.tab;
      mem = a.mem;
    }

let get_var_binding k gl idx =
  match k with
  | Bot -> failwith "varbinding cannot work here"
  | Def a ->
      VariableMem.find_in_map a.var idx gl
      |> VariableMem.M.bindings |> List.hd |> fst

(* abstract domain operations *)
let join (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, _ -> k2
  | _, Bot -> k1
  | Def k1, Def k2 ->
      let ops' = Operandstack.join (k1.var, k1.ops) (k2.var, k2.ops) in
      let var' = VariableMem.join k1.var k2.var in
      let mem' = Linearmem.join k1.mem k2.mem in
      let tab' = Tables.join k1.tab k2.tab in
      return { ops = ops'; var = var'; tab = tab'; mem = mem' }

let widen (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> Bot
  | Bot, _ -> k2
  | _, Bot -> failwith "bottom widening"
  | Def k1, Def k2 ->
      let ops' = Operandstack.widen (k1.var, k1.ops) (k2.var, k2.ops) in
      let var' = VariableMem.widen k1.var k2.var in
      let mem' = Linearmem.widen k1.mem k2.mem in
      let tab' = Tables.widen k1.tab k2.tab in
      return { ops = ops'; var = var'; tab = tab'; mem = mem' }

let leq (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> true
  | _, Bot -> false
  | Bot, _ -> true
  | Def k1, Def k2 ->
      Operandstack.leq (k1.var, k1.ops) (k2.var, k2.ops)
      && VariableMem.leq k1.var k2.var
      && Linearmem.leq k1.mem k2.mem
      && Tables.leq k1.tab k2.tab

let eq (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> true
  | _, Bot -> false
  | Bot, _ -> false
  | Def k1, Def k2 ->
      Operandstack.eq (k1.var, k1.ops) (k2.var, k2.ops)
      && VariableMem.eq k1.var k2.var
      && Linearmem.eq k1.mem k2.mem && Tables.eq k1.tab k2.tab

let le (k1 : t) (k2 : t) = leq k1 k2 && not (eq k1 k2)

let new_fun_ctx k locs =
  k >>= fun a ->
  let var' = VariableMem.new_ a.var locs in
  update_varmem var' k |> update_operandstack []

let func_res _k_from _k_to tp =
  _k_from >>= fun from ->
  _k_to >>= fun to_ ->
  let _to_sk = Operandstack.concretize_ret to_.ops to_.var in
  let _peeked_conc =
    List.map
      (fun x ->
        Operand.Expression
          (Operand.concretize_in_exp from.var x, Operand.type_of_operand x))
      (peek_n_operand tp _k_from)
  in
  let _sk_to = _peeked_conc @ _to_sk in
  let _vmem' = VariableMem.return_ from.var to_.var in
  return { ops = _sk_to; var = _vmem'; tab = to_.tab; mem = to_.mem }
