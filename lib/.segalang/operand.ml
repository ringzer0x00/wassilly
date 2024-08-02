type t = Value.value

let lub = Value.lub
let widen = Value.valueWidening
let leq = Value.included
let eq = Value.eq
let le o1 o2 = leq o1 o2 && not (eq o1 o2)
