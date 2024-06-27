module MS = Memories.Frame
module OS = Memories.Operandstack
open Memories.Operandstack

type ad = Memories.Variablememory.aprondomain

let int_unop (_ : Wasm.Ast.IntOp.unop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let int_binop (_ : Wasm.Ast.IntOp.binop) (_ : MS.t) :
    MS.t * Memories.Operandstack.stack =
  failwith ""

let realop _ _ : MS.t * Memories.Operandstack.stack = failwith ""

let const (n : Wasm.Ast.num) (vm : Memories.Operandstack.varmemories) =
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
  [ Expression (const_expr vm v) ]

let mul_expr vm l r =
  let l_ex = OS.operand_to_expr vm l in
  let r_ex = OS.operand_to_expr vm r in
  Expression (Apronext.Texprext.binary Apronext.Texprext.Mul l_ex r_ex)

let div_expr _ _ _ = failwith ""
let add_expr _ _ _ = failwith ""
let sub_expr _ (*ad*) _ _ (*operands*) = failwith ""
let neg_expr _ (*ad*) _ (*operand*) = failwith ""
