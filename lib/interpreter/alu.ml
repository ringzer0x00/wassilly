module MS = Memories.Frame
open Wasm.Types

let int_unop (_ : Wasm.Ast.IntOp.unop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let int_binop (_ : Wasm.Ast.IntOp.binop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let realop _ _ : MS.t * Memories.Operandstack.stack = failwith ""

let _const (n : Wasm.Ast.num) (_ : MS.t) =
  let _n_string = Wasm.Values.string_of_num n.it in
  let t = Wasm.Values.type_of_num n.it in
  match t with
  | F32Type | F64Type -> failwith "typed"
  | I32Type | I64Type -> failwith "typed"

let const (n : Wasm.Ast.num) (ms : MS.t) : MS.t =
  let _r =
    match n.it with
    | F32 c ->
        let c = Wasm.F32.to_float c in
        Apronext.Intervalext.of_float c c
    | F64 c ->
        let c = Wasm.F64.to_float c in
        Apronext.Intervalext.of_float c c
    | I32 c ->
        let c = Wasm.I32.to_int_s c in
        Apronext.Intervalext.of_int c c
    | I64 c ->
        let c = Wasm.I64.to_int_s c in
        Apronext.Intervalext.of_int c c
  in
  MS.push [ Value _r ] ms
