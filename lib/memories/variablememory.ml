open Variablemem

type t = { loc : LocalVar.t; glob : GlobalVar.t }

let join vm1 vm2 =
  {
    loc = LocalVar.join vm1.loc vm2.loc;
    glob = GlobalVar.join vm1.glob vm2.glob;
  }

let widen vm1 vm2 =
  {
    loc = LocalVar.widen vm1.loc vm2.loc;
    glob = GlobalVar.widen vm1.glob vm2.glob;
  }

let filter_loc ms _ : t = ms
let filter_glob ms _ : t = ms

let return_context finished continuation : t =
  { loc = continuation.loc; glob = finished.glob }

let leq vm1 vm2 =
  LocalVar.leq vm1.loc vm2.loc && GlobalVar.leq vm1.glob vm2.glob

let eq vm1 vm2 = LocalVar.eq vm1.loc vm2.loc && GlobalVar.eq vm1.glob vm2.glob
let le vm1 vm2 = leq vm1 vm2 && not (eq vm1 vm2)
