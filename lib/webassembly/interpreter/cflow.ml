open Datastructures.Monad.DefBot
open Fixpoint.Answer
module MS = Memories.Memorystate
module SCG = Fixpoint.Scg
module LM = Fixpoint.Labelmap.LabelMap

type abool = Datastructures.Abstractbit.t

(*NOTE: this belongs to operand*)
let intbool (exp : Memories.Operand.operand) (ms : MS.ms) =
  let t, f = Memories.Operand.boole_filter exp ms.var in
  let vm_t' : MS.VariableMem.t =
    { loc = ms.var.loc; glob = ms.var.glob; ad = t }
  in
  let vm_f' : MS.VariableMem.t =
    { loc = ms.var.loc; glob = ms.var.glob; ad = f }
  in
  let ms_t ms = MS.update_varmem vm_t' (Def ms) in
  let ms_f ms = MS.update_varmem vm_f' (Def ms) in
  match (Apronext.Apol.is_bottom t, Apronext.Apol.is_bottom f) with
  | true, true -> (Bot, Bot)
  | false, false -> (ms_t ms, ms_f ms)
  | true, false -> (Bot, ms_f ms)
  | false, true -> (ms_t ms, Bot)

let cond ms =
  let cond = MS.peek_operand ms |> List.hd in
  let ms' = MS.pop_operand ms in
  (cond, ms')

let filter_cond c (ms : MS.t) : MS.t * MS.t =
  match ms with Bot -> (Bot, Bot) | Def ms -> intbool c ms

let ite_condition ms =
  let c, ms' = cond ms in
  filter_cond c ms'

let enter_label _l ms mod_ =
  ms >>= fun _ ->
  let in_, _ =
    match _l with
    | Memories.Operand.Label lab ->
        Memories.Label.type_of_peeked_label lab
        |> Memories.Label.extract_type_of_label mod_
    | _ -> failwith "booooooo enter label bnoooo"
  in
  let vals, ms' =
    ( MS.peek_n_operand (List.length in_) ms,
      MS.pop_n_operand (List.length in_) ms )
  in
  Memories.Memorystate.push_operand (vals @ [ _l ]) ms'

let monad_step c1 ca f =
  match c1 with
  | Bot -> (Bot, ca, SCG.SCC.empty)
  | Def d -> ( match d.nat with Def _ -> f d | Bot -> (c1, ca, SCG.SCC.empty))

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

let end_of_func r pres =
  return { nat = Bot; br = LM.empty; return = MS.join r pres.p_return }

let seq_answer r1 r2 =
  r1 >>= fun res1 ->
  r2 >>= fun res2 ->
  return
    {
      nat = res2.nat;
      br = LM.lub res1.br res2.br;
      return = MS.join res1.return res2.return;
    }

let func_answer (k_to : res t) = k_to >>= fun to_ -> to_.return

let call_answer par ms_body =
  return { nat = ms_body; br = par.p_br; return = par.p_return }

let prep_call ms vals mod_ locs typ_idx =
  let gettype (mod_ : Memories.Instance.instance) idx =
    let t = List.nth mod_.types idx in
    t.it
  in
  let typ_ = gettype mod_ (Int32.to_int typ_idx) in
  let _ti, _to =
    (*list * list*)
    match typ_ with FuncType (_ti, _to) -> (_ti, _to)
  in
  let bindings_input =
    List.mapi
      (fun i x : Memories.Variablemem.MapKey.t ->
        {
          i = Int32.of_int i;
          t =
            (match x with
            | Wasm.Types.NumType t -> t
            | _ -> failwith "call @ eval @ bindings_input");
        })
      _ti
  in
  let vals_as_interval =
    List.map
      (fun o ->
        Memories.Memorystate.concretize_expr
          (Memories.Memorystate.concretize_operand o ms)
          ms)
      vals
  in
  let ms' = MS.new_fun_ctx ms (_ti @ locs) in
  ms' >>=? fun d ->
  let vals =
    List.map2
      (fun o i ->
        Memories.Operand.Expression
          ( Memories.Operand.const_expr d.var i,
            Memories.Operand.type_of_operand o ))
      vals vals_as_interval
  in
  let ms'' =
    List.fold_right2
      (fun b v m -> MS.assign_var m Loc b v)
      bindings_input vals ms'
  in
  ms''

let test_lub_pans a pres =
  a >>= fun r ->
  return
    {
      nat = r.nat;
      br = LM.lub r.br pres.p_br;
      return = MS.join r.return pres.p_return;
    }

let br depth ms p_ans cache modul_ ft fixf =
  let label = MS.peek_nth_label ms depth in
  let _tin, _tout =
    match label with
    | Some (Memories.Operand.Label l) ->
        Memories.Label.type_of_peeked_label l
        |> Memories.Label.extract_type_of_label modul_
    | Some _ -> failwith "cannot do it"
    | None -> ft
  in
  match label with
  | Some (Memories.Operand.Label (BlockLabel b)) ->
      let _vals, ms' =
        ( MS.peek_n_operand (List.length _tout) ms,
          MS.pop_n_operand (List.length _tout) ms )
      in
      let ms'' = MS.pop_n_labels ms' (depth + 1) in
      let ms''' = MS.push_operand _vals ms'' in
      ( Def
          {
            nat = Bot;
            br = LM.add_lub b.cmd ms''' p_ans.p_br;
            return = p_ans.p_return;
          },
        cache,
        SCG.SCC.empty )
  | Some (Memories.Operand.Label (LoopLabel l)) ->
      let _vals, ms' =
        ( MS.peek_n_operand (List.length _tin) ms,
          MS.pop_n_operand (List.length _tin) ms )
      in
      let ms'' = MS.pop_n_labels ms' (depth + 1) in
      (*let ms'' =
        MS.push_operand [ Memories.Operand.Label (LoopLabel l) ] ms''
      in*)
      let ms''' = MS.push_operand _vals ms'' in

      fixf l.cmd ms''' true
      (*this is wrong... probably, i think i should do stack manips beforehand*)
  | None ->
      let _vals, ms' =
        ( MS.peek_n_operand (List.length _tout) ms,
          MS.pop_n_operand (List.length _tout) ms )
      in
      let ms'' =
        if not (MS.is_lsk_empty ms') then MS.pop_n_labels ms' depth else ms'
      in
      let ms''' = MS.push_operand _vals ms'' in
      ( Def { nat = Bot; br = p_ans.p_br; return = MS.join p_ans.p_return ms''' },
        cache,
        SCG.SCC.empty )
  | _ -> failwith "cannot br without a target label"
