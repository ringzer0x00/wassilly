open Variablemem

type t = { loc : LocalVar.t; glob : GlobalVar.t }

let return_context finished continuation : t =
  { loc = continuation.loc; glob = finished.glob }
