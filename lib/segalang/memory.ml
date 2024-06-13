module VarMemory = Varmemory.VarMemory

module Memory = struct
  module VM = VarMemory

  type t = { vm : VM.t; opsk : int list }
end
