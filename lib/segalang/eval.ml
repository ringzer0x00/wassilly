type funcs = Command.Funcs.t
type call = Call.t
type stack = Stack.t
type result = Result.t
type partial_result = Result.partial_result
type cache = Cache.t
type scg = Scg.t

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
  | [] -> failwith "Instructions.end_of_block prec"
  | c1 :: c2 ->
      let (res1, cache', scg_h) : result * cache * scg =
        match c1 with
        | Val _ -> failwith "val"
        | Block (_res_arity, block_body) ->
            let label =
              Label.block { natcont = c2; brcont = c2; typ = _res_arity }
            in
            let b_prec = Instructions.enter_block label prec in
            let _b_call = (b_prec, block_body) in
            let r_b, cache', scg_b =
              fixpoint funcs (_b_call, false) _stack cache pres eval
            in
            (Resultsemantics.block_result r_b block_body, cache', scg_b)
        | Loop (_res_arity, _stmt) -> failwith "see block"
        | Sub | Sum | Mul ->
            (Resultsemantics.simplecmd_result prec pres, cache, Scg.empty)
        | Neg -> (Resultsemantics.simplecmd_result prec pres, cache, Scg.empty)
        | Br _ ->
            (*br semantics*)
            failwith "({ nat = BOT; br = ... ; return }, _cache, Scg.empty)"
        | If (_res_arity, _stmt_true, _stmt_false) -> failwith "p2p join"
        | Binop _bop ->
            failwith " ({ nat = prec; br; return }, _cache, Scg.empty)"
        | Unop _uop ->
            failwith "({ nat = prec; br; return }, _cache, Scg.empty)"
        | _ -> failwith ""
      in
      let (res2, cache'', scg_t) : result * cache * scg =
        match res1 with
        | Bot -> (res1, cache', Scg.empty)
        | Def res1 ->
            fixpoint funcs
              ((res1.nat, c2), false)
              _stack cache'
              (Result.pres_of_result res1)
              eval
      in
      let r = Resultsemantics.seq_result res1 res2 in
      (r, cache'', Scg.union scg_h scg_t)
