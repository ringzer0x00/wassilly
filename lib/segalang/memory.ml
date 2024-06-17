module VM = Varmemory
module OS = Operandstack
module LS = Labelstack

type ms = { vm : VM.t; opsk : OS.t; lsk : LS.t }
type t = Def of ms | Bot

let is_bot = function Bot -> true | Def _ -> false

(*monadic operators*)
let return x = Def x

let bind (x, y) op =
  match (x, y) with
  | Bot, Bot -> Bot
  | Def a, Bot | Bot, Def a -> Def a
  | Def a, Def b -> op a b

let ( >>= ) = bind

(*lowlevel ops*)
let lowlevel_widen m1 m2 =
  { vm = VM.widen m1.vm m2.vm; opsk = OS.widen m1.opsk m2.opsk; lsk = m1.lsk }
(*lsk is assumed to be the same on flow merges*)

let lowlevel_lub m1 m2 =
  { vm = VM.join m1.vm m2.vm; opsk = OS.lub m1.opsk m2.opsk; lsk = m1.lsk }
(*lsk is assumed to be the same on flow merges*)

(*magic*)
let widen m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_widen a b)
let join m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_lub a b)
let leq _ _ : bool = failwith ""
let eq _ _ : bool = failwith ""
let le m1 m2 = leq m1 m2 && not (eq m1 m2)
