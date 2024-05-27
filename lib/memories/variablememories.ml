open Variablemem

type t = { loc : LocalVar.t; glob : GlobalVar.t }

let join _ _ = failwith ""
let widen _ _ = failwith ""

let return_context finished continuation : t =
  { loc = continuation.loc; glob = finished.glob }
