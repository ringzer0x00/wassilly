module Command = Command.Language
module Memory = Memory.Memory
module M = Map.Make (Command)

type t = Memory.t M.t

let empty : t = M.empty
let bot = empty
let add_raw c ms lm : t = M.add c ms lm
let singleton c ms = M.singleton c ms

let lub _lm1 _lm2 : t =
  M.union (fun _key m1 m2 -> Some (Memory.join m1 m2)) _lm1 _lm2

let widen _lm1 _lm2 : t =
  M.union (fun _key m1 m2 -> Some (Memory.widen m1 m2)) _lm1 _lm2

let add_lub c ms lm = lub (M.singleton c ms) lm
let leq _ _ = failwith ""
let eq _ _ = failwith ""
let le lm1 lm2 = leq lm1 lm2 && not (eq lm1 lm2)
