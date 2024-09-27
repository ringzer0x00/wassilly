open Datastructures.Monad.DefBot
open Fixpoint.Answer

let join_ms = Memories.Memorystate.join

let implies (i : Importspec.Term.implies) _ms =
  let _res, _ass, _calls = i in
  (*evaluate _res and push to stack, evaluate _ass and set in _ms*)
  (_ms, _calls)

let when_ _clause _ms =
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
  let _r, calls =
    match p with
    | Func (_name, _funsig, _impl) ->
        let _ms' = "miao, i have to prepare!!!!" in
        implication _impl _ms
    | Glob (_name, _typ_, _val_) -> (glob _name _typ_ _val_ _ms, [])
    | Table (_name, _ttyp, _tbinds, _unspec) ->
        (table _name _ttyp _tbinds _unspec _ms, [])
  in
  ({ nat = Bot; br = bot_pa.p_br; return = _r }, calls)
(*return { p_br = ans_bot.p_br; p_return = ms }*)
