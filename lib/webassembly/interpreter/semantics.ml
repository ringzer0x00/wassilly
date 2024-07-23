open Memories.Label
open Fixpoint.Answer
open Datastructures.Monad.DefBot
module SCG = Fixpoint.Scg.SCC

let br depth ms p_ans cache modul_ fixf =
  let label = MS.peek_nth_label ms depth in
  let _, _t =
    match label with
    | Some (Memories.Operandstack.Label l) ->
        Memories.Label.type_of_peeked_label l
        |> Memories.Label.extract_type_of_label modul_
    | Some _ -> failwith "cannot do it"
    | None -> failwith "(until funcs have a block) this is the reference case"
  in
  let _vals, ms' =
    (MS.peek_n_operand (List.length _t) ms, MS.pop_n_operand (List.length _t) ms)
  in
  let ms' = MS.pop_n_labels ms' (depth + 1) in
  let ms' = MS.push_operand _vals ms' in
  match label with
  | Some (Memories.Operandstack.Label (BlockLabel b)) ->
      ( Def
          {
            nat = Bot;
            br = LM.add_lub b.cmd ms' p_ans.p_br;
            return = p_ans.p_return;
          },
        cache,
        SCG.empty )
  | Some (Memories.Operandstack.Label (LoopLabel l)) -> fixf l ms
  | None ->
      (*return-like case -> legacy, it should be an error!!!!*)
      ( Def { nat = Bot; br = p_ans.p_br; return = MS.join p_ans.p_return ms' },
        cache,
        SCG.empty )
  | _ -> failwith "cannot br without a target label"

let invoke = 0
