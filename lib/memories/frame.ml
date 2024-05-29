module SK = Datastructures.Liststack
module LocalVar = Variablemem.LocalVar
module GlobalVar = Variablemem.GlobalVar

type cont (*probably a program, a wasm instr sequence*)

type t = {
  ops : Operandstack.t;
  var : Variablememories.t;
  cont : cont;
  mem : Linearmem.t;
  tab : Tables.t;
  lsk : Label.t;
}

let peek = SK.peek
let peek_n = SK.peek_n
let pop = SK.pop
let pop_n = SK.pop_n

let update_operandstack ops' k =
  {
    ops = ops';
    var = k.var;
    cont = k.cont;
    mem = k.mem;
    tab = k.tab;
    lsk = k.lsk;
  }

let pop_operand k : t = update_operandstack (k.ops |> pop) k
let pop_n_operand n k : t = update_operandstack (k.ops |> pop_n n) k
let peek_operand k = k.ops |> peek
let peek_binop k = k.ops |> peek_n 2
let peek_n n k = k.ops |> peek_n n

(*join : ops, loc, glob
   check : cont*)
let join (k1 : t) (k2 : t) =
  if k1.cont != k2.cont then failwith "cannot join on different continuations"
  else
    let ops' = Operandstack.join (k1.var, k1.ops) (k2.var, k2.ops) in
    let var' = Variablememories.join k1.var k2.var in
    let mem' = Linearmem.join k1.mem k2.mem in
    let tab' = Tables.join k1.tab k2.tab in
    {
      ops = ops';
      var = var';
      cont = k1.cont;
      tab = tab';
      mem = mem';
      lsk = k1.lsk;
    }

let widen (k1 : t) (k2 : t) =
  if k1.cont != k2.cont then failwith "cannot widen on different continuations"
  else
    let ops' = Operandstack.widen (k1.var, k1.ops) (k2.var, k2.ops) in
    let var' = Variablememories.widen k1.var k2.var in
    let mem' = Linearmem.widen k1.mem k2.mem in
    let tab' = Tables.widen k1.tab k2.tab in
    {
      ops = ops';
      var = var';
      cont = k1.cont;
      tab = tab';
      mem = mem';
      lsk = k1.lsk;
    }

let leq (k1 : t) (k2 : t) =
  Operandstack.leq (k1.var, k1.ops) (k2.var, k2.ops)
  && Variablememories.leq k1.var k2.var
  && Linearmem.leq k1.mem k2.mem
  && Tables.leq k1.tab k2.tab

let eq (k1 : t) (k2 : t) =
  Operandstack.eq (k1.var, k1.ops) (k2.var, k2.ops)
  && Variablememories.eq k1.var k2.var
  && Linearmem.eq k1.mem k2.mem && Tables.eq k1.tab k2.tab

let le (k1 : t) (k2 : t) = leq k1 k2 && not (eq k1 k2)
let filter_loc _ctx _c = failwith ""
(*Variablememories.filter_loc ms.var c*)

let filter_glob _ctx _c = failwith "Variablememories.filter_glob ms.var c"
