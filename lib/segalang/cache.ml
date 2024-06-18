(*maps Call (Env, Command) to Stable, Val*)
type stability = Stable | Unstable

include Map.Make (Call)

type tt = (stability * Result.t) t
type t = tt

let empty : t = empty
let call_in_cache _ _ = failwith ""
