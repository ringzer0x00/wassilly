(*maps Call (Env, Command) to Stable, Val*)

module Result = Memories.Answer

module Cache = struct
  include Map.Make (Call.Call)

  type stability = Stable | Unstable

  let call_in_cache = find_opt
  let empty : (stability * Result.t) t = empty
end
