(*maps Call (Env, Command) to Stable, Val*)
type stability = Stable | Unstable

module Memory = Memories.Memorystate

module Cache = struct
  include Map.Make (Call.Call)

  let empty : (stability * Memory.t) t = empty
end
