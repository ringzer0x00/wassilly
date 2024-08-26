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

let int_testop (u : Wasm.Ast.IntOp.testop) (ms : MS.t) =
  match u with Eqz -> Instructions.eqz ms

let int_relop (u : Wasm.Ast.IntOp.relop) (ms : MS.t) =
  match u with
  | GeS -> Instructions.ge_s ms
  | GtS -> Instructions.gt_s ms
  | LeS -> Instructions.le_s ms
  | Eq -> Instructions.eq ms
  | Ne -> Instructions.ne ms
  | LtS -> Instructions.lt_s ms
  | GeU -> Instructions.cmpstub ms
  | GtU -> Instructions.cmpstub ms
  | LeU -> Instructions.cmpstub ms
  | LtU -> Instructions.cmpstub ms

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
  | Shl -> Instructions.l_shift ms
  | RemU -> failwith "remu"
  | Rotl -> Instructions.shift_stub ms (*stub*)
  | Rotr -> Instructions.shift_stub ms (*stub*)
  | ShrS -> Instructions.shift_stub ms (*stub*)
  | ShrU -> Instructions.shift_stub ms (*stub*)

let float_binop (_o : Wasm.Ast.FloatOp.binop) (_ms : MS.t) =
  match _o with
  | Add -> Instructions.add _ms
  | Sub -> Instructions.sub _ms
  | Div -> Instructions.divs _ms
  | Mul -> Instructions.mul _ms
  | CopySign
    (* copy just the sign bit from second to the first number :>
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
  | Ceil -> Instructions.ceil ms
  | Floor -> Instructions.floor ms
  | Nearest -> Instructions.nearest ms
  | Trunc -> Instructions.trunc ms

let float_relop (o : Wasm.Ast.FloatOp.relop) (ms : MS.t) =
  match o with
  | Eq -> Instructions.eq ms
  | Ge -> Instructions.ge_s ms
  | Gt -> Instructions.gt_s ms
  | Le -> Instructions.le_s ms
  | Lt -> Instructions.lt_s ms
  | Ne -> Instructions.ne ms

let int_cvtop (_o : Wasm.Ast.IntOp.cvtop) (ms : MS.t) =
  match _o with
  | ExtendSI32 (*extend to 64bit version, keep sign*) ->
      Instructions.extend_s_i32 ms
  | ExtendUI32 (*re-interpret and extend to 64bit version*) ->
      failwith "convert to unsigned and then change type"
  | WrapI64 (*~~*) -> failwith "i64 to i32 (reducing the value mod 2^32)"
  | ReinterpretFloat (*~~*) ->
      failwith "-0 as a floating point -> -2147483648"
      (*cannot use apron cast, must use bits*)
  | TruncSF32 | TruncSF64 -> failwith ""
  | TruncUF32 | TruncUF64 -> failwith "unsigned"
  | TruncSatSF32 | TruncSatSF64 | TruncSatUF32 | TruncSatUF64 ->
      failwith "sat????"
(*
   The semantics are the same as the corresponding non-_sat instructions, except:
    Instead of trapping on positive or negative overflow, they return the maximum or minimum integer value, respectively, and do not trap. 
    (This behavior is also referred to as "saturating".)
    Instead of trapping on NaN, they return 0 and do not trap.
*)

let float_cvtop (_o : Wasm.Ast.FloatOp.cvtop) (ms : MS.t) =
  match _o with
  | DemoteF64 -> Instructions.demote_f64 ms
  | ConvertSI32 -> failwith "int32 to float32"
  | ConvertUI32 -> failwith "int32 -> unsigned int32 -> float"
  | ConvertSI64 -> failwith "see above"
  | ConvertUI64 -> failwith "see above"
  | PromoteF32 -> failwith "f32 to f64"
  | ReinterpretInt -> failwith "int -> float (bits)"
