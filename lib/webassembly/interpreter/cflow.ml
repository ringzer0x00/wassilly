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

let end_of_func r pres =
  return { nat = Bot; br = pres.p_br; return = MS.join r pres.p_return }

let seq_answer r1 r2 =
  r1 >>= fun res1 ->
  r2 >>= fun res2 ->
  return
    {
      nat = res2.nat;
      br = LM.lub res1.br res2.br;
      return = MS.join res1.return res2.return;
    }

let func_answer (_k_to : res t) =
  (*unsure about this, maybe i need the natural cont too?*)
  match _k_to with Def to_ -> to_.return | Bot -> MS.bot

let call_answer par ms_body =
  return { nat = ms_body; br = par.p_br; return = par.p_return }

let prep_call ms vals mod_ locs typ_idx =
  let gettype (mod_ : Wasm.Ast.module_) idx =
    let t = List.nth mod_.it.types idx in
    t.it
  in
  let typ_ = gettype mod_ (Int32.to_int typ_idx) in
  let _ti =
    (*list * list*)
    match typ_ with FuncType (_ti, _to) -> _ti
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
  let ms' = MS.new_fun_ctx ms locs in
  let ms''' =
    List.fold_right2
      (fun b v m -> MS.assign_var m Loc b v)
      bindings_input vals ms'
  in
  ms'''
(*
  let typ_ = gettype modul_ (Int32.to_int typ_idx.it) in
  let _ti =
    (*list * list*)
    match typ_ with FuncType (_ti, _to) -> (_ti)
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
  let _ms'' = MS.new_fun_ctx _ms _ti in
  let ms''' =
    List.fold_right2
      (fun b v m -> MS.assign_var m Loc b v)
      bindings_input _vals _ms''
  in
  ms'''*)
