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

let bind (x, y) op =
  match (x, y) with
  | Bot, Bot -> Bot
  | Def a, Bot | Bot, Def a -> Def a
  | Def a, Def b -> op a b

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

let block_result r_b block_body =
  match r_b with
  | Bot -> Bot
  | Def r_b ->
      return
        {
          nat = Memory.join r_b.nat (Labelmap.res_label block_body r_b.br);
          br = Labelmap.remove block_body r_b.br;
          return = r_b.return;
        }

(*magic*)
let widen m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_widen a b)
let join m1 m2 = (m1, m2) >>= fun a b -> return (lowlevel_join a b)
let leq _ _ = failwith ""
let le _ _ = failwith ""
