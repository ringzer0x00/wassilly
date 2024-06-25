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
  | Def a, Bot | Bot, Def a -> return a
  | Def a, Def b -> op a b

let ( >>= ) = bind

let empty =
  return
    {
      vm = VM.empty (Apronext.Apol.top (Apronext.Environmentext.make [||] [||]));
      opsk = [];
      lsk = Labelstack.empty;
    }

(*lowlevel ops*)

let lowlevel_widen m1 m2 =
  { vm = VM.widen m1.vm m2.vm; opsk = OS.widen m1.opsk m2.opsk; lsk = m1.lsk }
(*lsk is assumed to be the same on flow merges*)

let lowlevel_lub m1 m2 =
  { vm = VM.join m1.vm m2.vm; opsk = OS.lub m1.opsk m2.opsk; lsk = m1.lsk }
(*lsk is assumed to be the same on flow merges*)

let lowlevel_leq m1 m2 =
  match (m1, m2) with
  | Bot, Bot -> true
  | Bot, Def _ -> true
  | Def _, Bot -> true
  | Def m1, Def m2 -> VM.leq m1.vm m2.vm && OS.leq m1.opsk m2.opsk

let ( <=* ) = lowlevel_leq

let lowlevel_eq m1 m2 =
  match (m1, m2) with
  | Bot, Bot -> true
  | Bot, _ | _, Bot -> false
  | Def m1, Def m2 -> VM.eq m1.vm m2.vm && OS.eq m1.opsk m2.opsk

let ( =* ) = lowlevel_eq

(*magic*)
let widen m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_widen a b)
let join m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_lub a b)
let leq m1 m2 : bool = lowlevel_leq m1 m2
let eq m1 m2 : bool = lowlevel_eq m1 m2
let le m1 m2 = m1 <=* m2 && not (m1 =* m2)
