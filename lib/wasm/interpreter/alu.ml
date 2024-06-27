module MS = Memories.Frame
open Memories.Operandstack

type ad = Memories.Variablememory.aprondomain

let int_unop (_ : Wasm.Ast.IntOp.unop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let int_binop (_ : Wasm.Ast.IntOp.binop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let realop _ _ : MS.t * Memories.Operandstack.stack = failwith ""

let const (n : Wasm.Ast.num) =
  let v =
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
  [ Value v ]

let mul_expr (_ : ad) l r =
  let _exp = Apronext.Texprext.binary Apronext.Texprext.Mul l r in
  failwith "exp"

let div_expr _ _ _ = failwith ""
let add_expr _ _ _ = failwith ""
let sub_expr _ (*ad*) _ _ (*operands*) = failwith ""
let neg_expr _ (*ad*) _ (*operand*) = failwith ""
