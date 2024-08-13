module MS = Memories.Memorystate
module OS = Memories.Operandstack
module VM = Memories.Variablemem.VariableMem

type ad = VM.aprondomain

let int_unop (_u : Wasm.Ast.IntOp.unop) (ms : MS.t) =
  match _u with
  | Popcnt (* X *) -> Instructions.popcnt ms
  | Clz (* X *) | Ctz (* X *) | ExtendS _ (* not sure *) ->
      failwith "unop int @ alu"

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
  | And (*X*)
  | Or (*X*)
  | RemU | Rotl | Rotr | Shl (* ~ *)
  | ShrS (* ~ *)
  | ShrU (* ~ *)
  | Xor (*X*) ->
      failwith "int_binop @ alu other instr"

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) =
  match _o with
  | Add -> Instructions.add _ms
  | Sub -> Instructions.sub _ms
  | Div -> Instructions.divs _ms
  | Mul -> Instructions.mul _ms
  | CopySign | Max | Min -> failwith "float binop"

let float_testop (_t : Wasm.Ast.FloatOp.testop) (_ms : MS.t) =
  match _t with _ -> failwith "no float testop?"

let float_unop (o : Wasm.Ast.FloatOp.unop) (ms : MS.t) =
  match o with
  | Neg -> Instructions.neg ms
  | Sqrt -> Instructions.sqrt ms
  | Abs -> failwith "absolute value"
  | Ceil -> failwith "round up"
  | Floor -> failwith "round down"
  | Nearest -> failwith "round to nearest int"
  | Trunc -> failwith "discard fractional, float -> float"

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
  | ExtendSI32 -> Instructions.extend_s_i32 _ms
  | ExtendUI32 -> failwith "convert to unsigned and then change type"
  | WrapI64 -> failwith "i64 to i32 (reducing the value mod 2^32)"
  | ReinterpretFloat -> failwith "float -> int (bits)"
  | TruncSF32 | TruncSF64 | TruncSatSF32 | TruncSatSF64 | TruncSatUF32
  | TruncUF32 | TruncUF64 | TruncSatUF64 ->
      failwith "cvt int"

let float_cvtop (_o : Wasm.Ast.FloatOp.cvtop) (_ms : MS.t) =
  match _o with
  | ConvertSI32 -> failwith "int32 to float32"
  | ConvertUI32 -> failwith "int32 -> unsigned int32 -> float"
  | ConvertSI64 -> failwith "see above"
  | ConvertUI64 -> failwith "see above"
  | PromoteF32 -> failwith "f32 to f64"
  | DemoteF64 -> failwith "f64 to f32"
  | ReinterpretInt -> failwith "int -> float (bits)"
