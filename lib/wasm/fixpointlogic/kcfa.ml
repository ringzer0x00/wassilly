(*not necessary for now!*)

module CTX = struct
  type t = Memories.Callstack.t

  let compare = compare
end

module LabelMap = struct
  module M = Map.Make (CTX)
  module C = Call.Call

  type call = C.t

  let k = 2

  type t = call M.t

  (*find_opt*)
  (*add*)
end
