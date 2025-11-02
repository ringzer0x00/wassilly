open Datastructures.Monad.DefBot

module Call = Call.Call
module MS = Memories.Memorystate

module Base = Set.Make (Call)

module SCC = struct
  include Base

  let equivalent_by_cmd cmd =
    Seq.find (fun (_, cmd') -> cmd = cmd')

  let merge_states ms_old ms_new =
    match (ms_old, ms_new) with
    | Bot, _ -> ms_new
    | _, Bot -> ms_old
    | _ -> MS.widen ms_old ms_new

  let canonicalize call set =
    let ms, cmd = call in
    match equivalent_by_cmd cmd (to_seq set) with
    | None -> (ms, cmd), set
    | Some ((ms_old, _) as existing) ->
        let merged = merge_states ms_old ms in
        let set' = Base.remove existing set in
        ((merged, cmd), set')

  let add call set =
    let call', set' = canonicalize call set in
    Base.add call' set'

  let singleton call = add call empty

  let remove call set =
    let _, cmd = call in
    match equivalent_by_cmd cmd (to_seq set) with
    | None -> set
    | Some existing -> Base.remove existing set

  let diff s1 s2 = Base.fold remove s2 s1
  let union s1 s2 = Base.fold (fun call acc -> add call acc) s2 s1

  let in_scg (ms, cmd) g =
    match equivalent_by_cmd cmd (to_seq g) with
    | None -> false
    | Some (msC, _) -> MS.eq ms msC
end
