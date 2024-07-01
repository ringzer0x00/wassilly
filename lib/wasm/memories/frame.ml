module SK = Datastructures.Liststack
module VariableMem = Variablemem.VariableMem

type cont (*probably a program, a wasm instr sequence*)

type ms = {
  ops : Operandstack.t;
  var : VariableMem.t;
  mem : Linearmem.t;
  tab : Tables.t;
  lsk : Labelstack.t;
}

type t = Def of ms | Bot

let return x = Def x
let bind x op = match x with Bot -> Bot | Def a -> op a
let ( >>= ) = bind
let bind_peek x op = match x with Bot -> failwith "" | Def a -> op a
let ( >== ) = bind_peek
let bot = Bot
let peek = SK.peek
let peek_n = SK.peek_n
let pop = SK.pop
let pop_n = SK.pop_n
let peek_nth_label = Labelstack.peek_nth

let update_operandstack ops' (k : t) =
  k >>= fun a ->
  return { ops = ops'; var = a.var; mem = a.mem; tab = a.tab; lsk = a.lsk }

let update_labelstack lsk' (k : t) =
  k >>= fun a ->
  return { ops = a.ops; var = a.var; mem = a.mem; tab = a.tab; lsk = lsk' }

let pop_operand k : t = k >>= fun a -> update_operandstack (a.ops |> pop) k

let pop_n_operand n k : t =
  k >>= fun a -> update_operandstack (a.ops |> pop_n n) k

let pop_n_labels k n = k >== fun a -> update_labelstack (a.lsk |> pop_n n) k
let peek_n_operand n k = k >== fun a -> a.ops |> peek_n n
let peek_operand k = peek_n_operand 1 k
let peek_binop k = peek_n_operand 2 k
let peek_nth_label k n = k >== fun a -> a.lsk |> peek_nth_label n
let push_operand x k = k >>= fun a -> update_operandstack (x @ a.ops) k
let push_label x k = k >>= fun a -> update_labelstack (x :: a.lsk) k

let is_lsk_empty k =
  match k with Bot -> failwith "" | Def kx -> Labelstack.is_empty kx.lsk

let join (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> Bot
  | Bot, _ -> k2
  | _, Bot -> k1
  | Def k1, Def k2 ->
      let ops' = Operandstack.join (k1.var, k1.ops) (k2.var, k2.ops) in
      let var' = VariableMem.join k1.var k2.var in
      let mem' = Linearmem.join k1.mem k2.mem in
      let tab' = Tables.join k1.tab k2.tab in
      Def { ops = ops'; var = var'; tab = tab'; mem = mem'; lsk = k1.lsk }

let widen (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> Bot
  | Bot, _ -> k2
  | _, Bot -> k1
  | Def k1, Def k2 ->
      let ops' = Operandstack.widen (k1.var, k1.ops) (k2.var, k2.ops) in
      let var' = VariableMem.widen k1.var k2.var in
      let mem' = Linearmem.widen k1.mem k2.mem in
      let tab' = Tables.widen k1.tab k2.tab in
      Def { ops = ops'; var = var'; tab = tab'; mem = mem'; lsk = k1.lsk }

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
let filter _ctx _c = failwith ""
(*Variablememories.filter_loc ms.var c*)
