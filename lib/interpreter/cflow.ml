module MS = Memories.Frame

type abool = Datastructures.Abstractbit.t

let intbool _exp _ms : abool = Top
(*sat soving shenanigans.
  is it zero, non-zero or can it be both?*)

let cond ms =
  let cond = MS.peek_operand ms in
  let ms' = MS.pop_operand ms in
  (cond, ms')

let filter_cond c ms =
  let eval = intbool c ms in
  match eval with
  (*branch_true, branch_false*)
  | Top -> (ms, ms)
  | One -> (ms, MS.bot)
  | Zero -> (MS.bot, ms)
  | Bot -> (MS.bot, MS.bot)

let ite_condition ms =
  let c, ms' = cond ms in
  filter_cond c ms'
