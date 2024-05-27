module Command = struct
  type t = Wasm.Ast.instr list

  let compare = compare
end

module Call = struct
  type call = Memories.Memorystate.t * Command.t
  type t = call

  let compare = compare
end
