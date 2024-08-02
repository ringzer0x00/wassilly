(*maps Call (Env, Command) to Stable, Val*)
type stability = Stable | Unstable

module Cache = struct
  include Map.Make (Call.Call)

  let empty : (stability * Value.value) t = empty
end
