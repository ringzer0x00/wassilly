module Call = struct
  type call = Memory.Memory.t * Command.Command.t
  type t = call

  let compare = compare
end
