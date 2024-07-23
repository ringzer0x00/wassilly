module MS = Memories.Frame
module OS = Memories.Operandstack
module VM = Memories.Variablemem.VariableMem

type ad = VM.aprondomain

let int_unop (_u : Wasm.Ast.IntOp.unop) (_ : MS.t) =
  match _u with Clz | Ctz | ExtendS _ | Popcnt -> failwith "unop int @ alu"

let int_testop (_u : Wasm.Ast.IntOp.testop) (ms : MS.t) =
  match _u with Eqz -> Instructions.eqz ms

let int_relop (u : Wasm.Ast.IntOp.relop) (ms : MS.t) =
  match u with
  | GeS -> Instructions.ge_s ms
  | GtS -> Instructions.gt_s ms
  | LeS -> Instructions.le_s ms
  | Eq -> Instructions.eq ms
  | Ne -> Instructions.ne ms
  | LtS -> Instructions.lt_s ms
  | GtU -> failwith "not implemented, gtu"
  | GeU -> failwith "not implemented, GeU"
  | LeU -> failwith "not implemented, LeU"
  | LtU -> failwith "not implemented LtU (UINT_MAX + 1)"

let int_binop (o : Wasm.Ast.IntOp.binop) (ms : MS.t) =
  match o with
  | Add -> Instructions.add ms
  | Sub -> Instructions.sub ms
  | Mul -> Instructions.mul ms
  | DivS -> Instructions.divs ms
  | RemS -> Instructions.rems ms
  | DivU -> failwith "divu @ binop @ alu"
  | And | Or | RemU | Rotl | Rotr | Shl | ShrS | ShrU | Xor ->
      failwith "int_binop @ alu other instr"

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) =
  match _o with
  | Add | CopySign | Div | Max | Min | Mul | Sub -> failwith "float binop"

let float_testop (_t : Wasm.Ast.FloatOp.testop) (_ms : MS.t) =
  match _t with _ -> failwith "no float testop?"

let float_unop (o : Wasm.Ast.FloatOp.unop) (ms : MS.t) =
  match o with
  | Neg -> Instructions.neg ms
  | Sqrt -> Instructions.sqrt ms
  | Abs | Ceil | Floor | Nearest | Trunc -> failwith "float @ alu"

let float_relop (_o : Wasm.Ast.FloatOp.relop) (_ms : MS.t) =
  match _o with Eq | Ge | Gt | Le | Lt | Ne -> failwith "float relop @ alu"
