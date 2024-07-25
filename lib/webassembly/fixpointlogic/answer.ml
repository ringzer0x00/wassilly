module MS = Memories.Memorystate
module LM = Labelmap.LabelMap
open Datastructures.Monad.DefBot

(*jmp map label(corpo) -> MS*)
type partial_answer = { p_br : LM.t; p_return : MS.t }

let p_br p = p.p_br
let p_ret p = p.p_return

type res = { nat : MS.t; br : LM.t; return : MS.t }

let nat a = a.nat
let br a = a.br
let ret a = a.return
let bot_pa = { p_br = LM.empty; p_return = Bot }

let lowlevel_join r1 r2 =
  {
    nat = MS.join (nat r1) (nat r2);
    return = MS.join (ret r1) (ret r2);
    br = LM.lub (br r1) (br r2);
  }

let lowlevel_widen r1 r2 =
  {
    nat = MS.widen (nat r1) (nat r2);
    return = MS.widen (ret r1) (ret r2);
    br = LM.widen (br r1) (br r2);
  }

let j x y =
  match (x, y) with
  | Bot, Bot ->
      Printf.printf "BOTBOT";
      Bot
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

let pans_of_answer { nat; br; return } =
  ignore nat;
  { p_br = br; p_return = return }
