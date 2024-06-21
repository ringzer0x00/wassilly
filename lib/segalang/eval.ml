type funcs = Command.Funcs.t
type call = Call.t
type stack = Stack.t
type result = Result.t
type partial_result = Result.partial_result
type cache = Cache.t
type scg = Scg.t

let cmd_result = Resultsemantics.simplecmd_result

let fixpoint funcs (((_, expr) as call), loopable) stack cache pres eval =
  match loopable with
  | false -> eval funcs call stack cache pres
  | true -> (
      match Cache.call_in_cache call cache with
      | Some cached -> (
          let stable, resCached = cached in
          match stable with
          | Cache.Stable -> (resCached, cache, Scg.empty)
          | Cache.Unstable -> (resCached, cache, Scg.singleton call))
      | None -> (
          match Stack.expr_in_stack expr stack with
          | true -> (Result.bot, cache, Scg.singleton call)
          | false -> Iterate.iterate funcs call stack cache pres eval))

let rec eval (funcs : funcs) (call : call) (_stack : stack) (cache : cache) pres
    : result * cache * scg =
  let prec, prog = call in
  match prog with
  | [] -> (cmd_result (Instructions.end_of_block prec) pres, cache, Scg.empty)
  | c1 :: c2 ->
      let (res1, cache', scg_h) : result * cache * scg =
        match c1 with
        | Val v ->
            (cmd_result (Instructions.const_val v prec) pres, cache, Scg.empty)
        | Block (_res_arity, block_body) ->
            let label =
              Label.block { body = block_body; brcont = c2; typ = _res_arity }
            in
            let b_prec = Instructions.enter_block label prec in
            let _b_call = (b_prec, block_body) in
            let r_b, cache', scg_b =
              fixpoint funcs (_b_call, false) _stack cache pres eval
            in
            (Resultsemantics.block_result r_b block_body, cache', scg_b)
        | Loop (_res_arity, loop_body) ->
            let label =
              Label.loop
                { body = loop_body; brcont = c1 :: c2; typ = _res_arity }
            in
            let b_prec = Instructions.enter_block label prec in
            let _b_call = (b_prec, loop_body) in
            let r_b, cache', scg_b =
              fixpoint funcs (_b_call, true) _stack cache pres eval
            in
            (Resultsemantics.block_result r_b loop_body, cache', scg_b)
        | Mul -> (cmd_result (Instructions.mul prec) pres, cache, Scg.empty)
        | Sub -> (cmd_result (Instructions.sub prec) pres, cache, Scg.empty)
        | Sum -> (cmd_result (Instructions.add prec) pres, cache, Scg.empty)
        | Neg -> (cmd_result (Instructions.neg prec) pres, cache, Scg.empty)
        | Br depth -> (
            let target_label, _stack_popped =
              (Instructions.brpeek prec depth, Instructions.br prec depth)
            in
            match target_label with
            | None ->
                Printf.printf "target_label non c'è!!!";
                ( Result.return
                    { nat = Memory.Bot; br = pres.br; return = pres.return },
                  cache,
                  Scg.empty )
            | Some _l -> (
                match _l with
                | BlockLabel _ ->
                    ( Result.return
                        {
                          nat = Memory.Bot;
                          br =
                            Labelmap.add_lub (Label.body _l) _stack_popped
                              pres.br;
                          return = pres.return;
                        },
                      cache,
                      Scg.empty )
                | LoopLabel lc ->
                    fixpoint funcs
                      ((_stack_popped, lc.brcont), true)
                      _stack cache pres eval))
        | BrIf _ ->
            let _prec, _op_to_check = Instructions.intbool prec in
            (*br semantics*)
            failwith
              "({ nat = deve fare la valutazione; br = semantica di br! ; \
               return }, _cache, Scg.empty)"
        | If (_res_arity, stmt_true, stmt_false) ->
            let prec, _op_to_check = Instructions.intbool prec in
            let label_t, label_f =
              ( Label.block { body = stmt_true; brcont = c2; typ = _res_arity },
                Label.block { body = stmt_false; brcont = c2; typ = _res_arity }
              )
            in
            let t_prec, f_prec =
              ( Instructions.enter_block label_t prec,
                Instructions.enter_block label_f prec )
            in
            let t_call, f_call = ((t_prec, stmt_true), (f_prec, stmt_false)) in
            let t_b, cache', scg_t =
              fixpoint funcs (t_call, false) _stack cache pres eval
            in
            let f_b, cache'', scg_f =
              fixpoint funcs (f_call, false) _stack cache' pres eval
            in
            let t_res, f_res =
              ( Resultsemantics.block_result t_b stmt_true,
                Resultsemantics.block_result f_b stmt_false )
            in
            (Result.join t_res f_res, cache'', Scg.union scg_t scg_f)
        | Binop _bop ->
            failwith " ({ nat = prec; br; return }, _cache, Scg.empty)"
        | Unop _uop ->
            failwith "({ nat = prec; br; return }, _cache, Scg.empty)"
        | _ -> failwith ""
      in
      let (res2, cache'', scg_t) : result * cache * scg =
        match res1 with
        | Bot -> (Bot, cache', Scg.empty)
        | Def res1 ->
            fixpoint funcs
              ((res1.nat, c2), false)
              _stack cache'
              (Result.pres_of_result res1)
              eval
      in
      let r = Resultsemantics.seq_result res1 res2 in
      (r, cache'', Scg.union scg_h scg_t)
