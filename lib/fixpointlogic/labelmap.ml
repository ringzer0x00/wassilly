module Command = Language.Command.Command
module Memory = Memories.Frame

module LabelMap = struct
  module M = Map.Make (Command)

  type t = Memory.t M.t

  let empty : t = M.empty
  let add c ms lm : t = M.add c ms lm

  let lub _lm1 _lm2 : t =
    M.union (fun _key m1 m2 -> Some (Memory.join m1 m2)) _lm1 _lm2

  let widen _lm1 _lm2 : t =
    M.union (fun _key m1 m2 -> Some (Memory.widen m1 m2)) _lm1 _lm2
end
