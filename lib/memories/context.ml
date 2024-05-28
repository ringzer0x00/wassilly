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

let join _ _ = failwith ""
let widen _ _ = failwith ""
let leq _ _ = failwith ""
let eq _ _ = failwith ""
let le _ _ = failwith ""

let topmost_ctx = function
  | [] -> failwith "cannot peek @ topmost"
  | h :: _ -> h

let update_topmost h' = function
  | [] -> failwith "cannot replace topmost"
  | _ :: t -> h' :: t

let pop_operand (k : t) = failwith ""
let peek_operand _ = failwith ""
let peek_binop _ = failwith ""
