module MS = Memories.Frame
module OS = Memories.Operandstack
module VM = Memories.Variablemem.VariableMem

type ad = VM.aprondomain

let int_unop (_u : Wasm.Ast.IntOp.unop) (_ : MS.t) = failwith "int unop @ alu"

let int_testop (_u : Wasm.Ast.IntOp.testop) (ms : MS.t) =
  match _u with Eqz -> Instructions.eqz ms

let int_relop (u : Wasm.Ast.IntOp.relop) (ms : MS.t) =
  match u with
  | GeS -> Instructions.ge_s ms
  | GtS | GtU -> Instructions.gt_s ms
  | LeS -> Instructions.le_s ms
  | Eq -> Instructions.eq ms
  | GeU -> failwith "not implemented, GeU"
  | LeU -> failwith "not implemented, LeU"
  | LtS -> failwith "not implemented LtS"
  | LtU -> failwith "not implemented LtU"
  | Ne -> failwith "not implemented Ne"

let int_binop (o : Wasm.Ast.IntOp.binop) (ms : MS.t) =
  match o with
  | Add -> Instructions.add ms
  | Sub -> Instructions.sub ms
  | Mul -> Instructions.mul ms
  | DivS -> Instructions.divs ms
  | DivU -> failwith "divu @ binop @ alu"
  | _ -> failwith "int_binop @ alu other instr"

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) =
  failwith "float @ ali"

let float_testop (_t : Wasm.Ast.FloatOp.testop) (_ms : MS.t) =
  failwith "float testop @ ali"

let float_unop (o : Wasm.Ast.FloatOp.unop) (ms : MS.t) =
  match o with Neg -> Instructions.neg ms | _ -> failwith "float @ alu"

let float_relop (_o : Wasm.Ast.FloatOp.relop) (_ms : MS.t) =
  failwith "float relop @ ali"
