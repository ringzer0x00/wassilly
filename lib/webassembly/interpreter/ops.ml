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

let eval_loadop ({ ty; align; offset; pack } : Wasm.Ast.loadop) _ms =
  ignore align;
  let _ =
    (*suuport 1 memory, no pack!*)
    assert (Int32.equal Int32.zero offset);
    match pack with None -> assert true | Some _ -> assert false
    (*Wasm.Types
      type pack_size = Pack8 | Pack16 | Pack32 | Pack64
      type extension = SX | ZX*)
  in

  (* align = 0,1,2,3 for load_8, load_16,load_32, load_64*)
  (* offset is the memory index *)
  match ty with
  | Wasm.Types.I32Type -> Instructions.load_i32 _ms
  | Wasm.Types.I64Type -> Instructions.load_i64 _ms
  | Wasm.Types.F32Type -> Instructions.load_f32 _ms
  | Wasm.Types.F64Type -> Instructions.load_f64 _ms

let eval_storeop ({ ty; align; offset; pack } : Wasm.Ast.storeop) _ms =
  let _ =
    assert (Int32.equal Int32.zero offset);
    match pack with None -> assert true | Some _psize -> assert false
  in
  ignore align;
  match ty with
  | Wasm.Types.I32Type -> Instructions.store_i32 _ms
  | Wasm.Types.I64Type -> failwith "store i64"
  | Wasm.Types.F32Type -> failwith "store f32"
  | Wasm.Types.F64Type -> failwith "store f64"
