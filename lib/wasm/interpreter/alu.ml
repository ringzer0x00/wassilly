module MS = Memories.Frame
module OS = Memories.Operandstack

type ad = Memories.Variablememory.aprondomain

let int_unop (_u : Wasm.Ast.IntOp.unop) (_ : MS.t) = failwith ""

let int_binop (o : Wasm.Ast.IntOp.binop) (ms : MS.t) =
  match o with
  | Add -> Instructions.add ms
  | Sub -> Instructions.sub ms
  | Mul -> Instructions.mul ms
  | DivS -> Instructions.divs ms
  | DivU -> failwith ""
  | _ -> failwith ""

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) = failwith ""

let float_unop (o : Wasm.Ast.FloatOp.unop) (ms : MS.t) =
  match o with Neg -> Instructions.neg ms | _ -> failwith ""
