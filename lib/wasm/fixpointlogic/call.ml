module Call = struct
  type call = Memories.Frame.t * Language.Command.Command.t
  type t = call

  let compare = compare
end
