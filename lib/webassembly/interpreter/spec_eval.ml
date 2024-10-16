open Datastructures.Monad.DefBot
open Fixpoint.Answer
open Importspec.Term

let apron_expr_parse (m : MS.ms) e =
  Apron.Parser.texpr1_of_string m.var.ad.env e

let join_ms = Memories.Memorystate.join
let printer = Utilities.Printer.print

let eval_val (v : value) (ms : MS.t) loc_bindings =
  let massage_value bindings c =
    List.fold_left
      (fun c (Param (_, p), b) ->
        Str.global_replace (Str.regexp_string p)
          (Apron.Var.to_string (MS.VariableMem.apronvar_of_binding b Loc))
          c)
      c bindings
  in
  ms >>=? fun def ->
  let interval =
    match v with
    | Num i -> i
    | Rel exp ->
        let e = apron_expr_parse def (massage_value loc_bindings exp) in
        MS.concretize_expr e ms
  in
  Memories.Operand.const_expr def.var interval

let eval_result (Result (t, v)) _ms loc_bindings =
  let t' = Importspec.Wasmtypes.as_wasm_numeric t in
  let v' = eval_val v _ms loc_bindings in
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
    (eval_result (Result (t_par, _v)) _ms [])

let table _n _tt _tb _unsp _ms = _ms >>=? fun d -> return d

let global_assignment (idx_ass, _wasmtype, (_value : value)) ms
    (_local_bindings : (param * MS.VariableMem.binding) list) =
  let op = eval_result (Result (_wasmtype, _value)) ms _local_bindings in
  let binding : Memories.Variablemem.MapKey.t =
    { i = idx_ass; t = Importspec.Wasmtypes.as_wasm_numeric _wasmtype }
  in
  let ms' = Memories.Memorystate.assign_var ms Glob binding op in
  ms'

let eval_assignment a m bindings (modi : Memories.Instance.instance) =
  match a with
  | GlobAss (n, t, v) -> global_assignment (n, t, v) m bindings
  | MemAss (_, _o_start, _val_, _wt) ->
      let _w, _s =
        match _wt with
        | I32Type | F32Type -> (4, 32)
        | I64Type | F64Type -> (8, 64)
      in
      let wasmtype = Importspec.Wasmtypes.as_wasm_numeric _wt in
      m >>=? fun d ->
      let operand_val =
        Memories.Operand.Expression (eval_val _val_ m bindings, wasmtype)
      in
      let _addr_val =
        Memories.Operand.Expression (eval_val _o_start m bindings, wasmtype)
      in
      let mem' =
        Exprs_math.store_standard d.var d.mem _addr_val operand_val wasmtype
          Int32.zero
      in
      Memories.Memorystate.update_linearmem mem' m
  | TableAss (_, TableBinding (_tabidx, fidx)) ->
      let _f_sig =
        match List.nth modi.funcs (Int32.to_int fidx) with
        | ImportedFunc (Func (_, FuncSig (p, r), _)) ->
            let i =
              List.map
                (fun (Param (wt, _)) ->
                  Wasm.Types.NumType (Importspec.Wasmtypes.as_wasm_numeric wt))
                p
            in
            let o =
              List.map
                (fun (ResultType x) ->
                  Wasm.Types.NumType (Importspec.Wasmtypes.as_wasm_numeric x))
                r
            in
            let t_converted = Wasm.Types.FuncType (i, o) in
            let t_indexed =
              List.mapi (fun i x -> (Int32.of_int i, x)) modi.types
            in
            let _idx_ft, _fsig =
              List.find
                (fun (_, (t : Wasm.Ast.type_)) -> t.it = t_converted)
                t_indexed
            in
            _idx_ft
        | Func f -> f.it.ftype.it
        | _ -> failwith "not interested"
      in
      m >>=? fun d ->
      let t' =
        [
          Memories.Table.set
            (_tabidx, (Some fidx, Some (Int32.of_int 0)))
            (List.hd d.tab);
        ]
      in
      let ms' = Memories.Memorystate.update_tables t' m in
      ms'

let implies (i : Importspec.Term.implies) (ms : MS.t) bindings
    (modi : Memories.Instance.instance) =
  match ms with
  | Bot -> (ms, [])
  | _ ->
      let res, _ass, calls = i in
      let ms' =
        List.fold_left (fun m a -> eval_assignment a m bindings modi) ms _ass
      in
      let res_eval = List.map (fun x -> eval_result x ms' bindings) res in
      let ms'' = Memories.Memorystate.push_operand res_eval ms' in
      (ms'', calls)

let when_ (_clause : precond list) (ms_start : MS.ms t) =
  ms_start >>=? fun d ->
  let _clause_as_constr =
    List.map (fun x -> Apron.Parser.tcons1_of_string d.var.ad.env x) _clause
  in
  let filter ad c = Memories.Variablemem.VariableMem.filter ad c in
  let neg_filter ad c = filter ad (Apronext.Tconsext.neg c) in
  let ms_t_vm =
    List.fold_left (fun ad c -> filter ad c) d.var _clause_as_constr
  in
  let ms_f_vm =
    List.fold_left (fun ad c -> neg_filter ad c) d.var _clause_as_constr
  in
  let ms_t = Memories.Memorystate.update_varmem ms_t_vm ms_start in
  let ms_f = Memories.Memorystate.update_varmem ms_f_vm ms_start in

  (ms_t, ms_f)

let prep_call ms vals (locs : param list) (typ_ : param list * resulttype list)
    =
  (*rewrite for this case*)
  let boh_locs (pars : param list) =
    List.mapi (fun i (Param (_wt, n)) -> (i, n)) pars
  in
  let _locs_conv = boh_locs locs in
  let maketype (tin, tout) =
    Wasm.Types.FuncType
      ( List.map
          (fun (Param (wt, _)) ->
            Wasm.Types.NumType (Importspec.Wasmtypes.as_wasm_numeric wt))
          tin,
        List.map
          (fun (ResultType wt) ->
            Wasm.Types.NumType (Importspec.Wasmtypes.as_wasm_numeric wt))
          tout )
  in
  let typ_conv = maketype typ_ in
  let ti, _to =
    match typ_conv with Wasm.Types.FuncType (_ti, _to) -> (_ti, _to)
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
      ti
  in
  let bindings_map = List.combine locs bindings_input in
  let ms' = MS.new_fun_ctx ms ti in
  let vals_as_interval =
    List.map
      (fun o ->
        Memories.Memorystate.concretize_expr
          (Memories.Memorystate.concretize_operand o ms)
          ms)
      vals
  in
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
    (*broken here apparently*)
    List.fold_left2
      (fun m v b -> MS.assign_var m Loc b v)
      ms' vals bindings_input
  in
  (ms'', bindings_map)

let rec implication (i : Importspec.Term.impl) (ms : MS.t)
    (bindings : (param * MS.VariableMem.binding) list) modi =
  match i with
  | Implies impl -> implies impl ms bindings modi
  | Implication (clause, impl, else_) ->
      let massage_clause bindings c =
        List.fold_left
          (fun c (Param (_, p), b) ->
            Str.global_replace (Str.regexp_string p)
              (Apron.Var.to_string (MS.VariableMem.apronvar_of_binding b Loc))
              c)
          c bindings
      in
      let clause' = List.map (fun c -> massage_clause bindings c) clause in
      let t, f = when_ clause' ms in
      let (t', _c_t), (f', _c_f) =
        ( implication (Implies impl) t bindings modi,
          implication else_ f bindings modi )
      in
      (join_ms t' f', List.append _c_t _c_f)

let eval (p : Importspec.Term.term) ms modi =
  (*Importspec.Term.pp_term Format.std_formatter p;*)
  let r, calls =
    match p with
    | Func (_name, funsig, impl) ->
        let t_in, _tout, n =
          match funsig with FuncSig (p, r) -> (p, r, List.length p)
        in
        let args, ms' =
          ( Memories.Memorystate.peek_n_operand n ms,
            Memories.Memorystate.pop_n_operand n ms )
        in
        printer Format.print_string "\t~ Imported Function parameters:\n\t\t# ";
        printer
          (List.iter (fun x ->
               Memories.Operand.print_operand x;
               Format.print_string ", "))
          args;
        printer Format.print_string "\n";
        printer Format.print_string "\t~ Concretized:\n\t\t";
        printer
          (List.iter (fun x ->
               let i = Memories.Memorystate.operand_as_interval x ms in
               Apronext.Intervalext.print Format.std_formatter i;
               Format.print_string ", "))
          args;
        printer Format.print_string "\n";

        (*let args' = List.map2 (fun x (Param (_, n)) -> (n, x)) args t_in in*)
        let ms'', bindings_map = prep_call ms' args t_in (t_in, _tout) in
        let in_called_ctx, cg = implication impl ms'' bindings_map modi in
        let in_caller_ctx =
          Memories.Memorystate.func_res in_called_ctx ms' (List.length _tout)
        in
        (in_caller_ctx, cg)
        (* after this I have to forget the ctx and go back to old one!!!!!! *)
    | Glob (name, typ_, val_) -> (glob name typ_ val_ ms modi, [])
    | Table (_name, _ttyp, _tbinds, _unspec) ->
        (table _name _ttyp _tbinds _unspec ms, [])
    | PostInst ass ->
        (List.fold_left (fun m a -> eval_assignment a m [] modi) ms ass, [])
  in
  match r with
  | Def _ -> (Def { nat = Bot; br = bot_pa.p_br; return = r }, calls)
  | Bot -> failwith "undef imported func!!!!"
(*return { p_br = ans_bot.p_br; p_return = ms }*)
