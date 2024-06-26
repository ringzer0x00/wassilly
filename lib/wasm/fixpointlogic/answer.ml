module MS = Memories.Frame
module LM = Labelmap.LabelMap
open Datastructures.Monad

(*jmp map label(corpo) -> MS*)
type res = { nat : MS.t; br : LM.t; return : MS.t }
type r = res t
type t = r

let bot = Bot

let lowlevel_join r1 r2 =
  {
    nat = MS.join r1.nat r2.nat;
    return = MS.join r1.return r2.return;
    br = LM.lub r1.br r2.br;
  }

let lowlevel_widen r1 r2 =
  {
    return = MS.widen r1.return r2.return;
    br = LM.widen r1.br r2.br;
    nat = MS.widen r1.nat r2.nat;
  }

let j x y =
  match (x, y) with
  | Bot, Bot -> Bot
  | Def a, Bot | Bot, Def a -> Def a
  | Def a, Def b -> return (lowlevel_join a b)

let w x y =
  match (x, y) with
  | Bot, Bot -> Bot
  | Def _a, Bot -> failwith "widening with bottom @ w @ result.ml"
  | Bot, Def a -> Def a
  | Def a, Def b -> return (lowlevel_widen a b)

let widen a1 a2 = w a1 a2
let lub a1 a2 = j a1 a2

let leq a1 a2 =
  match (a1, a2) with
  | Bot, Bot | Bot, Def _ -> true
  | Def _, Bot -> false
  | Def d1, Def d2 ->
      MS.leq d1.nat d2.nat && LM.leq d1.br d2.br && MS.leq d1.return d2.return

let eq m1 m2 =
  match (m1, m2) with
  | Bot, Bot -> true
  | Bot, Def _ | Def _, Bot -> false
  | Def d1, Def d2 ->
      MS.eq d1.nat d2.nat && LM.eq d1.br d2.br && MS.eq d1.return d2.return

let le a1 a2 = leq a1 a2 && not (eq a1 a2)
