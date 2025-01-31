let gt_matches (nt : Wasm.Types.num_type) (t : Term.wasmType) =
  match (nt, t) with
  | I32Type, I32Type -> true
  | I64Type, I64Type -> true
  | F32Type, F32Type -> true
  | F64Type, F64Type -> true
  | _ -> false

let as_wasm_numeric = function
  | Term.I32Type -> Wasm.Types.I32Type
  | I64Type -> I64Type
  | F32Type -> F32Type
  | F64Type -> F64Type
