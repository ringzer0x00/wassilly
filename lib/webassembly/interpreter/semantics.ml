open Instructions.LS
open Fixpoint.Answer
open Datastructures.Monad.DefBot
module SCG = Fixpoint.Scg.SCC

let br label ms' p_ans cache fixf =
  match label with
  | Some (BlockLabel b) ->
      ( Def
          {
            nat = Bot;
            br = LM.add_lub b.cmd ms' p_ans.p_br;
            return = p_ans.p_return;
          },
        cache,
        SCG.empty )
  | Some (LoopLabel l) -> fixf l ms'
  | None ->
      (*return-like case*)
      ( Def { nat = Bot; br = p_ans.p_br; return = MS.join p_ans.p_return ms' },
        cache,
        SCG.empty )

let invoke = 0
