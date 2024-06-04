module MS = Memories.Frame

let int_unop (_ : Wasm.Ast.IntOp.unop) (_ : MS.t) : MS.t * Memories.Operandstack.stack = failwith ""

let int_binop (_ : Wasm.Ast.IntOp.binop) (_ : MS.t) : MS.t * Memories.Operandstack.stack = failwith ""
let realop _ _ : 'a = failwith ""
