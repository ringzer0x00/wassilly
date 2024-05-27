let eval_unop (op : Wasm.Ast.unop) ms =
  match op with
  | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.intop intop ms
  | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop -> Alu.realop floatop ms
