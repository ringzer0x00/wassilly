module SK = Datastructures.Liststack

type cont (*probably a program, a wasm instr sequence*)

type t =
  | Def of {
      ops : Operandstack.t;
      var : Variablememory.t;
      cont : cont;
      mem : Linearmem.t;
      tab : Tables.t;
      lsk : Labelstack.t;
    }
  | Bot

let bot = Bot
let peek = SK.peek
let peek_n = SK.peek_n
let pop = SK.pop
let pop_n = SK.pop_n

let update_operandstack ops' (k : t) =
  match k with
  | Bot -> failwith ""
  | Def k ->
      Def
        {
          ops = ops';
          var = k.var;
          cont = k.cont;
          mem = k.mem;
          tab = k.tab;
          lsk = k.lsk;
        }

let pop_operand k : t =
  match k with
  | Bot -> failwith ""
  | Def kx -> update_operandstack (kx.ops |> pop) k

let pop_n_operand n k : t =
  match k with
  | Bot -> failwith ""
  | Def kx -> update_operandstack (kx.ops |> pop_n n) k

let peek_operand k =
  match k with Bot -> failwith "" | Def kx -> kx.ops |> peek

let peek_binop k =
  match k with Bot -> failwith "" | Def kx -> kx.ops |> peek_n 2

let peek_n n k =
  match k with Bot -> failwith "" | Def kx -> kx.ops |> peek_n n

let push x k =
  match k with
  | Bot -> failwith ""
  | Def kx -> update_operandstack (x @ kx.ops) k

(*join : ops, loc, glob
   check : cont*)
let join (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> Bot
  | Bot, _ -> k2
  | _, Bot -> k1
  | Def k1, Def k2 ->
      if k1.cont != k2.cont then
        failwith "cannot join on different continuations"
      else
        let ops' = Operandstack.join (k1.var, k1.ops) (k2.var, k2.ops) in
        let var' = Variablememory.join k1.var k2.var in
        let mem' = Linearmem.join k1.mem k2.mem in
        let tab' = Tables.join k1.tab k2.tab in
        Def
          {
            ops = ops';
            var = var';
            cont = k1.cont;
            tab = tab';
            mem = mem';
            lsk = k1.lsk;
          }

let widen (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> Bot
  | Bot, _ -> k2
  | _, Bot -> k1
  | Def k1, Def k2 ->
      if k1.cont != k2.cont then
        failwith "cannot widen on different continuations"
      else
        let ops' = Operandstack.widen (k1.var, k1.ops) (k2.var, k2.ops) in
        let var' = Variablememory.widen k1.var k2.var in
        let mem' = Linearmem.widen k1.mem k2.mem in
        let tab' = Tables.widen k1.tab k2.tab in
        Def
          {
            ops = ops';
            var = var';
            cont = k1.cont;
            tab = tab';
            mem = mem';
            lsk = k1.lsk;
          }

let leq (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> true
  | _, Bot -> false
  | Bot, _ -> true
  | Def k1, Def k2 ->
      Operandstack.leq (k1.var, k1.ops) (k2.var, k2.ops)
      && Variablememory.leq k1.var k2.var
      && Linearmem.leq k1.mem k2.mem
      && Tables.leq k1.tab k2.tab

let eq (k1 : t) (k2 : t) =
  match (k1, k2) with
  | Bot, Bot -> true
  | _, Bot -> false
  | Bot, _ -> false
  | Def k1, Def k2 ->
      Operandstack.eq (k1.var, k1.ops) (k2.var, k2.ops)
      && Variablememory.eq k1.var k2.var
      && Linearmem.eq k1.mem k2.mem && Tables.eq k1.tab k2.tab

let le (k1 : t) (k2 : t) = leq k1 k2 && not (eq k1 k2)
let filter _ctx _c = failwith ""
(*Variablememories.filter_loc ms.var c*)
