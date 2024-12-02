module Command = Language.Command.Command
module Memory = Memories.Memorystate
open Datastructures.Monad.DefBot

module LabelMap = struct
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

  let leq lm1 lm2 =
    if M.compare (fun a b -> if Memory.leq a b then -1 else 0) lm1 lm2 = -1 then
      true
    else false

  let eq lm1 lm2 = M.equal Memory.eq lm1 lm2
  let le lm1 lm2 = leq lm1 lm2 && not (eq lm1 lm2)

  let res_label l lm =
    let r = M.find_opt l lm in
    match r with None -> Bot | Some r -> r

  let remove = M.remove
end
