let eval_binop (op : Wasm.Ast.binop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_binop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop -> Alu.realop floatop ms
