module VarMemory = Varmemory.VarMemory
module OpStrack = Operandstack

module Memory = struct
  module VM = VarMemory
  module OS = OpStrack

  type t = { vm : VM.t; opsk : OS.t }
end
