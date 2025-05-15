module Call = Call.Call

module SCC = struct
  include Set.Make (Call)

  let in_scg (ms, cmd) g =
    let o =
      Seq.find
        (fun (msC, cmdC) -> cmd = cmdC && Memories.Memorystate.leq ms msC)
        (to_seq g)
    in
    match o with None -> false | Some _ -> true
end
