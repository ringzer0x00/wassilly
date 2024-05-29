module SK = Datastructures.Liststack
module LocalVar = Variablemem.LocalVar
module GlobalVar = Variablemem.GlobalVar

type 'a stack = 'a list
type cont (*probably a program, a wasm instr sequence*)

type ctx = {
  ops : Operandstack.t;
  loc : LocalVar.t;
  glob : GlobalVar.t;
  cont : cont;
}

type callstack = ctx stack
type t = callstack

let peek = SK.peek
let peek_n = SK.peek_n
let pop = SK.pop
let pop_n = SK.pop_n
let update_topmost = SK.update_topmost

let pop_operand cs : t =
  let tmost = peek cs in
  update_topmost
    {
      ops = tmost.ops |> pop;
      loc = tmost.loc;
      glob = tmost.loc;
      cont = tmost.cont;
    }
    cs

let pop_n_operand cs n : t =
  let tmost = peek cs in
  update_topmost
    {
      ops = tmost.ops |> pop_n n;
      loc = tmost.loc;
      glob = tmost.loc;
      cont = tmost.cont;
    }
    cs

let peek_operand cs = (peek cs).ops |> peek
let peek_binop cs = (peek cs).ops |> peek_n 2
let join (_ : t) (_ : t) = failwith ""
let widen (_ : t) (_ : t) = failwith ""
let leq (_ : t) (_ : t) = failwith ""
let eq (_ : t) (_ : t) = failwith ""
let le (_ : t) (_ : t) = failwith ""
