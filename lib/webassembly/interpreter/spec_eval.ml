open Datastructures.Monad.DefBot
open Fixpoint.Answer
open Importspec.Term

let apron_expr_parse (m : MS.ms) e =
  Apron.Parser.texpr1_of_string m.var.ad.env e

let join_ms = Memories.Memorystate.join

let eval_val (v : value) (ms : MS.t) =
  ms >>=? fun def ->
  let interval =
    match v with
    | Num i -> i
    | Rel exp ->
        let e = apron_expr_parse def exp in
        MS.concretize_expr e ms
  in
  Memories.Operand.const_expr def.var interval

let eval_result (Result (t, v)) _ms =
  let t' = Importspec.Wasmtypes.as_wasm_numeric t in
  let v' = eval_val v _ms in
  Memories.Operand.Expression (v', t')

let glob (_n : string) (t_par : wasmType) (_v : value) (_ms : MS.t)
    (_modi : Memories.Instance.instance) =
  let binding_type = Importspec.Wasmtypes.as_wasm_numeric t_par in
  let (Program ispec) = _modi.importspecs in
  let globs_indexed =
    List.filter_map
      (fun x -> match x with Glob (n, t, v) -> Some (n, t, v) | _ -> None)
      ispec
    |> List.mapi (fun i x -> (Int32.of_int i, x))
  in
  let idx =
    List.find
      (fun (_, (n, t, _)) -> if n = _n && t_par = t then true else false)
      globs_indexed
    |> fst
  in
  let binding : MS.VariableMem.binding = { i = idx; t = binding_type } in
  Memories.Memorystate.assign_var _ms Glob binding
    (eval_result (Result (t_par, _v)) _ms)

let table _n _tt _tb _unsp _ms = _ms >>=? fun d -> return d

let implies (i : Importspec.Term.implies) _ms =
  let _res, _ass, _calls = i in
  let _ = List.map (fun x -> eval_result x _ms) _res in
  (_ms, _calls)

let when_ (_clause : precond list) _ms =
  let ms_t, ms_f = (_ms, _ms) in
  (ms_t, ms_f)

let rec implication (i : Importspec.Term.impl) (_ms : MS.t) =
  match i with
  | Implies impl -> implies impl _ms
  | Implication (clause, impl, else_) ->
      let t, f = when_ clause _ms in
      let (t', _c_t), (f', _c_f) =
        (implication (Implies impl) t, implication else_ f)
      in
      (join_ms t' f', List.append _c_t _c_f)

let eval (p : Importspec.Term.term) _ms modi =
  let r, calls =
    match p with
    | Func (_name, _funsig, _impl) ->
        let _tin, _tout, _times_to_pop =
          match _funsig with FuncSig (p, r) -> (p, r, List.length p)
        in
        let _ms' = assert false in
        implication _impl _ms
    | Glob (_name, _typ_, _val_) -> (glob _name _typ_ _val_ _ms modi, [])
    | Table (_name, _ttyp, _tbinds, _unspec) ->
        (table _name _ttyp _tbinds _unspec _ms, [])
  in
  match r with
  | Def _ -> (Def { nat = Bot; br = bot_pa.p_br; return = r }, calls)
  | Bot -> failwith "undef imported func!!!!"
(*return { p_br = ans_bot.p_br; p_return = ms }*)