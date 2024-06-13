module VarMemory = Varmemory.VarMemory
module OpStack = Operandstack

module Memory = struct
  module VM = VarMemory
  module OS = OpStack

  type t = { vm : VM.t; opsk : OS.t }

  let widen _ _ = failwith ""
  let join _ _ = failwith ""
end
