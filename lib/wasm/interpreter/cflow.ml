open Datastructures.Monad
open Fixpoint.Answer
module MS = Memories.Frame
module SCG = Fixpoint.Scg
module LM = Fixpoint.Labelmap.LabelMap

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

let enter_label l ms = MS.push_label l ms

let monad_step c1 ca f =
  match c1 with Bot -> (Bot, ca, SCG.SCC.empty) | Def d -> f d

let block_result r_b block_body =
  r_b >>= fun r ->
  return
    {
      nat = MS.join r.nat (LM.res_label block_body r.br);
      return = r.return;
      br = LM.remove block_body r.br;
    }

let simplecmd_answer r pres =
  return { nat = r; br = pres.p_br; return = pres.p_return }

let seq_answer r1 r2 =
  r1 >>= fun res1 ->
  r2 >>= fun res2 ->
  return
    {
      nat = res2.nat;
      br = LM.lub res1.br res2.br;
      return = MS.join res1.return res2.return;
    }

let fun_result r_f _block_body = r_f >>= fun _r -> failwith ""
