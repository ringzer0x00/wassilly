type t = Value.value

let lub = Value.lub
let widen = Value.valueWidening
let leq = Value.included
let eq = Value.eq
let le o1 o2 = leq o1 o2 && not (eq o1 o2)
let binop o1 o2 (f : t -> t -> t) = f o1 o2
let unop o (f : t -> t) = f o
