(*maps Call (Env, Command) to Stable, Val*)

module Memory = Memories.Frame

module Cache = struct
  include Map.Make (Call.Call)

  type stability = Stable | Unstable

  let call_in_cache = find_opt
  let empty : (stability * Memory.t) t = empty
end
