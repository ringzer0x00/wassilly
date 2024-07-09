(*maps Call (Env, Command) to Stable, Val*)

module Result = Answer

module Cache = struct
  module M = Map.Make (Call.Call)

  type stability = Stable | Unstable
  type t = (stability * Result.res Datastructures.Monad.t) M.t

  let empty : t = M.empty
  let call_in_cache k m = M.find_opt k m
  let find = M.find
  let mem = M.mem
  let add = M.add
end
