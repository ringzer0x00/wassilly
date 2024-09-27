open Datastructures.Monad.DefBot
open Fixpoint.Answer
open Importspec.Term

let join_ms = Memories.Memorystate.join

let eval_val (v : value) _ms =
  match v with Num _ -> failwith "" | Rel _ -> failwith ""

let eval_result (Result (t, v)) _ms =
  let _t =
    match t with F32Type | F64Type | I32Type | I64Type -> failwith ""
  in
  let _v = eval_val v in
  failwith "make operands"

let implies (i : Importspec.Term.implies) _ms =
  let _res, _ass, _calls = i in
  let _ = List.map (fun x -> eval_result x _ms) _res in
  (_ms, _calls)

let when_ (_clause : precond list) _ms =
  let ms_t, ms_f = (_ms, _ms) in
  (ms_t, ms_f)

let rec implication (i : Importspec.Term.impl) _ms =
  match i with
  | Implies impl -> implies impl _ms
  | Implication (clause, impl, else_) ->
      let t, f = when_ clause _ms in
      let (t', _c_t), (f', _c_f) =
        (implication (Implies impl) t, implication else_ f)
      in
      (join_ms t' f', List.append _c_t _c_f)

let glob _n _t _v _ms = _ms
let table _n _tt _tb _unsp _ms = _ms

let eval (p : Importspec.Term.term) _ms =
  let r, calls =
    match p with
    | Func (_name, _funsig, _impl) ->
        let _ms' = failwith "miao, i have to prepare!!!!" in
        implication _impl _ms
    | Glob (_name, _typ_, _val_) -> (glob _name _typ_ _val_ _ms, [])
    | Table (_name, _ttyp, _tbinds, _unspec) ->
        (table _name _ttyp _tbinds _unspec _ms, [])
  in
  match r with
  | Def _ -> (Def { nat = Bot; br = bot_pa.p_br; return = r }, calls)
  | Bot -> failwith "undef imported func!!!!"
(*return { p_br = ans_bot.p_br; p_return = ms }*)
