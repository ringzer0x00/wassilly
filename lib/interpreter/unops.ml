module MS = Memories.Frame

let eval_unop (op : Wasm.Ast.unop) ms =
  let ms', sk =
    match op with
    | Wasm.Values.I32 intop | Wasm.Values.I64 intop -> Alu.int_unop intop ms
    | Wasm.Values.F32 floatop | Wasm.Values.F64 floatop -> Alu.realop floatop ms
  in
  MS.push sk ms'
