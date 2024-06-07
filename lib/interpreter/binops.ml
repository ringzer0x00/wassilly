module MS = Memories.Frame

let eval_binop (op : Wasm.Ast.binop) ms =
  let ms', sk =
    match op with
    | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_binop intop ms
    | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop -> Alu.realop floatop ms
  in
  MS.push sk ms'
