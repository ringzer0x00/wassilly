module Call = struct
  type call = Memories.Memorystate.t * Language.Command.Command.t
  type t = call

  let compare = compare
end
