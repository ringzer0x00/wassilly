module MS = Memories.Memorystate
module OS = Memories.Operandstack
module VM = Memories.Variablemem.VariableMem

type ad = VM.aprondomain

let int_unop (_u : Wasm.Ast.IntOp.unop) (ms : MS.t) =
  match _u with
  | Popcnt -> Instructions.popcnt ms
  | Clz -> Instructions.clz ms
  | Ctz -> Instructions.ctz ms
  | ExtendS _ps (* not sure *) ->
      let _ =
        match _ps with Pack16 | Pack32 | Pack64 | Pack8 -> failwith ""
      in
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
  (*~~*)
  | GtU -> failwith "not implemented, gtu ( Signed+(2^size) )"
  | GeU -> Instructions.ge_u ms
  (*~~*)
  | LeU -> failwith "not implemented, LeU ( Signed+(2^size))"
  (*~~*)
  | LtU -> failwith "not implemented LtU ( Signed+(2^size))"

let int_binop (o : Wasm.Ast.IntOp.binop) (ms : MS.t) =
  match o with
  | Add -> Instructions.add ms
  | Sub -> Instructions.sub ms
  | Mul -> Instructions.mul ms
  | DivS -> Instructions.divs ms
  | RemS -> Instructions.rems ms
  | DivU -> failwith "divu @ binop @ alu"
  | And -> Instructions.l_and ms
  | Or -> Instructions.l_or ms
  | Xor -> Instructions.l_xor ms
  | RemU (*~~*)
  | Rotl (*~~*)
  | Rotr (*~~*)
  | Shl (*x^2*)
  | ShrS (* sign-preserving shift *)
  | ShrU (* sign-ignoring shift *) ->
      failwith "int_binop @ alu other instr"

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) =
  match _o with
  | Add -> Instructions.add _ms
  | Sub -> Instructions.sub _ms
  | Div -> Instructions.divs _ms
  | Mul -> Instructions.mul _ms
  | CopySign
    (* copy just the sing bit from second to the first number :>
       - `id`,
       - *-1 (and swap sup and inf),
       - LUB between `id` and *-1 (?) *)
  | Max (*max of the two vals*)
  | Min
    (*inf =  cases (l.inf,l.sup) (r.inf,r.sup):
      - l.inf < r.inf -> l.inf
      - l.inf >= r.inf -> r.inf
      sup = cases (l.inf,l.sup) (r.inf,r.sup):
      - l.sup < r.sup -> l.sup
      - l.sup >= r.sup -> r.sup *) ->
      failwith "float binop"

let float_testop (_t : Wasm.Ast.FloatOp.testop) (_ms : MS.t) =
  match _t with _ -> failwith "no float testop?"

let float_unop (o : Wasm.Ast.FloatOp.unop) (ms : MS.t) =
  match o with
  | Neg -> Instructions.neg ms
  | Sqrt -> Instructions.sqrt ms
  | Abs -> Instructions.abs ms
  | Ceil -> failwith "round up" (*apron: up*)
  | Floor -> failwith "round down" (*apron: down*)
  | Nearest -> failwith "round to nearest int" (*apron: near*)
  | Trunc -> failwith "discard fractional" (*apron: zero*)

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
  | ExtendUI32 (*~~*) -> failwith "convert to unsigned and then change type"
  | WrapI64 (*~~*) -> failwith "i64 to i32 (reducing the value mod 2^32)"
  | ReinterpretFloat (*~~*) -> failwith "float -> int (bits)"
  | TruncSF32 | TruncSF64 | TruncSatSF32 | TruncSatSF64 | TruncSatUF32
  | TruncUF32 | TruncUF64 | TruncSatUF64 ->
      failwith "cvt int"

let float_cvtop (_o : Wasm.Ast.FloatOp.cvtop) (ms : MS.t) =
  match _o with
  | DemoteF64 -> Instructions.demote_f64 ms
  | ConvertSI32 -> failwith "int32 to float32"
  | ConvertUI32 -> failwith "int32 -> unsigned int32 -> float"
  | ConvertSI64 -> failwith "see above"
  | ConvertUI64 -> failwith "see above"
  | PromoteF32 -> failwith "f32 to f64"
  | ReinterpretInt -> failwith "int -> float (bits)"
