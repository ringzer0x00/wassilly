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
