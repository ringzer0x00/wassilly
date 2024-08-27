module MS = Memories.Memorystate

let eval_binop (op : Wasm.Ast.binop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_binop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop ->
      Alu.float_binop floatop ms

let eval_unop (op : Wasm.Ast.unop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_unop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop ->
      Alu.float_unop floatop ms

let eval_relop (op : Wasm.Ast.relop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_relop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop ->
      Alu.float_relop floatop ms

let eval_testop (op : Wasm.Ast.testop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_testop intop ms

let eval_cvtop (op : Wasm.Ast.cvtop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_cvtop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop ->
      Alu.float_cvtop floatop ms

let eval_loadop (op : Wasm.Ast.loadop) _ms =
  match op with
  | { ty = Wasm.Types.I32Type; align = _i; offset = _i32; pack = _p } ->
      failwith "l i32"
  | { ty = Wasm.Types.I64Type; align = _i; offset = _i32; pack = _p } ->
      failwith "load i64"
  | { ty = Wasm.Types.F32Type; align = _i; offset = _i32; pack = _p } ->
      failwith "load f32"
  | { ty = Wasm.Types.F64Type; align = _i; offset = _i32; pack = _p } ->
      failwith "load f64"
(*
type loadop = (num_type, (pack_size * extension) option) memop*)

(*
type storeop = (num_type, pack_size option) memop*)
