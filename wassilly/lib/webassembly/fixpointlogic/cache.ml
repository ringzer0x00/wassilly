(*maps Call (Env, Command) to Stable, Val*)

module Result = Answer

module Cache = struct
  module M = Map.Make (Call.Call)

  type stability = Stable | Unstable
  type t = (stability * Result.res Datastructures.Monad.DefBot.t) M.t

  let empty : t = M.empty
  let _call_in_cache k m = M.find_opt k m

  let call_in_cache (ms, cmd) m =
    let o =
      Seq.find
        (fun ((msC, cmdC), _) -> cmd = cmdC && Result.MS.leq ms msC)
        (M.to_seq m)
    in
    match o with None -> None | Some r -> Some (snd r)

  let lub c c' = M.union (fun _ _v v' -> Some v') c c' (*someday*)
  let find = M.find
  let mem = M.mem
  let add = M.add
end
