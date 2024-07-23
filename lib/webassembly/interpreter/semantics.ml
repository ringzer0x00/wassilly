open Memories.Label
open Fixpoint.Answer
open Datastructures.Monad.DefBot
module SCG = Fixpoint.Scg.SCC

let br depth ms p_ans cache modul_ ft fixf =
  let label = MS.peek_nth_label ms depth in
  let _, _t =
    match label with
    | Some (Memories.Operandstack.Label l) ->
        Memories.Label.type_of_peeked_label l
        |> Memories.Label.extract_type_of_label modul_
    | Some _ -> failwith "cannot do it"
    | None -> ft
  in
  let _vals, ms' =
    (MS.peek_n_operand (List.length _t) ms, MS.pop_n_operand (List.length _t) ms)
  in
  match label with
  | Some (Memories.Operandstack.Label (BlockLabel b)) ->
      let ms'' = MS.pop_n_labels ms' (depth + 1) in
      let ms''' = MS.push_operand _vals ms'' in
      ( Def
          {
            nat = Bot;
            br = LM.add_lub b.cmd ms''' p_ans.p_br;
            return = p_ans.p_return;
          },
        cache,
        SCG.empty )
  | Some (Memories.Operandstack.Label (LoopLabel l)) ->
      let ms'' = MS.pop_n_labels ms' (depth + 1) in
      let ms''' = MS.push_operand _vals ms'' in
      fixf l ms'''
      (*this is wrong... probably, i think i should do stack manips beforehand*)
  | None ->
      let ms'' =
        if not (MS.is_lsk_empty ms') then MS.pop_n_labels ms' depth else ms'
      in
      let ms''' = MS.push_operand _vals ms'' in
      ( Def { nat = Bot; br = p_ans.p_br; return = MS.join p_ans.p_return ms''' },
        cache,
        SCG.empty )
  | _ -> failwith "cannot br without a target label"

let invoke = 0
