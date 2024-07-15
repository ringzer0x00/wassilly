type mem = Memory.t
type lmap = Labelmap.t
type res = { nat : mem; br : lmap; return : mem }
type partial_result = { br : lmap; return : mem }

let pres_of_result (r : res) = { br = r.br; return = r.return }

type t = Def of res | Bot

let is_bot = function Bot -> true | Def _ -> false
let bot = Bot

(*monadic operators*)
let return x = Def x
let bind x op = match x with Bot -> Bot | Def a -> op a
let ( >>= ) = bind

let lowlevel_join r1 r2 =
  {
    return = Memory.join r1.return r2.return;
    br = Labelmap.lub r1.br r2.br;
    nat = Memory.join r1.nat r2.nat;
  }

let lowlevel_widen r1 r2 =
  {
    return = Memory.widen r1.return r2.return;
    br = Labelmap.widen r1.br r2.br;
    nat = Memory.widen r1.nat r2.nat;
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

(*magic*)
let widen m1 m2 = w m1 m2
let join m1 m2 = j m1 m2

let leq m1 m2 =
  match (m1, m2) with
  | Bot, Bot | Bot, Def _ -> true
  | Def _, Bot -> false
  | Def m1, Def m2 ->
      Memory.leq m1.nat m2.nat && Labelmap.leq m1.br m2.br
      && Memory.leq m1.return m2.return

let eq m1 m2 =
  match (m1, m2) with
  | Bot, Bot -> true
  | Bot, Def _ | Def _, Bot -> false
  | Def m1, Def m2 ->
      Memory.eq m1.nat m2.nat && Labelmap.eq m1.br m2.br
      && Memory.eq m1.return m2.return

let le m1 m2 = leq m1 m2 && not (eq m1 m2)
