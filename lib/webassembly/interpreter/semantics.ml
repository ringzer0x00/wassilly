open Memories.Label
open Fixpoint.Answer
open Datastructures.Monad.DefBot
module SCG = Fixpoint.Scg.SCC

let br label ms' p_ans cache _brt fixf  =
  match label with
  | Some (Memories.Operandstack.Label BlockLabel b) ->
      ( Def
          {
            nat = Bot;
            br = LM.add_lub b.cmd ms' p_ans.p_br;
            return = p_ans.p_return;
          },
        cache,
        SCG.empty )
  | Some (Memories.Operandstack.Label LoopLabel l) -> fixf l ms'
  | None ->
      (*return-like case*)
      ( Def { nat = Bot; br = p_ans.p_br; return = MS.join p_ans.p_return ms' },
        cache,
        SCG.empty )
  | _ -> failwith "cannot br without a target label"

let invoke = 0
