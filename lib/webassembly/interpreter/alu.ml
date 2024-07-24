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
  | GtU -> failwith "not implemented, gtu ( Signed+(2^size) )"
  | GeU -> Instructions.ge_u ms
  | LeU -> failwith "not implemented, LeU ( Signed+(2^size))"
  | LtU -> failwith "not implemented LtU ( Signed+(2^size))"

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

let float_relop (o : Wasm.Ast.FloatOp.relop) (ms : MS.t) =
  match o with
  | Eq -> Instructions.eq ms
  | Ge -> Instructions.ge_s ms
  | Gt -> Instructions.gt_s ms
  | Le -> Instructions.le_s ms
  | Lt -> Instructions.lt_s ms
  | Ne -> Instructions.ne ms

let int_cvtop (_o : Wasm.Ast.IntOp.cvtop) (_ms : MS.t) =
  match _o with
  | ExtendSI32 | ExtendUI32 | ReinterpretFloat | TruncSF32 | TruncSF64
  | TruncSatSF32 | TruncSatSF64 | TruncSatUF32 | WrapI64 | TruncUF32 | TruncUF64
  | TruncSatUF64 ->
      failwith "cvt int"

let float_cvtop (_o : Wasm.Ast.FloatOp.cvtop) (_ms : MS.t) =
  match _o with
  | ConvertSI32 | ConvertUI32 | ConvertSI64 | ConvertUI64 | PromoteF32
  | DemoteF64 | ReinterpretInt ->
      failwith "cvt int"
