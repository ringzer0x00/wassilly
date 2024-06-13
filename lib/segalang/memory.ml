module VM = Varmemory.VarMemory
module OS = Operandstack
module LS = Labelstack

type t = { vm : VM.t; opsk : OS.t; lsk : LS.t }

let widen _ _ = failwith ""
let join _ _ = failwith ""
