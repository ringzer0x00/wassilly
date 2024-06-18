type funcs = Command.Funcs.t
type call = Call.t
type stack = Stack.t
type result = Result.t
type partial_result = Result.partial_result
type cache = Cache.t
type scg = Scg.t

let fixpoint funcs (((_env, _expr) as call), _ifb) stack cache pres eval =
  match _ifb with
  | false -> eval funcs call stack cache pres
  | true -> failwith ""

let rec eval (funcs : funcs) (call : call) (_stack : stack) (_cache : cache)
    ({ br; return } as pres : partial_result) : result * cache * scg =
  let prec, prog = call in
  match prog with
  | [] -> failwith ""
  | c1 :: c2 ->
      let (res1, cache', scg_h) : result * cache * scg =
        match c1 with
        | Block (_res_arity, block_body) ->
            let _b_prec = prec in
            let _b_call = (_b_prec, block_body) in
            let r_b, cache_b, scg_b =
              fixpoint funcs (_b_call, false) _stack _cache pres eval
            in
            (Result.block_result r_b block_body, cache_b, scg_b)
        | Loop (_res_arity, _stmt) -> failwith "see block"
        | Sub | Sum | Mul ->
            (Result.return { nat = prec; br; return }, _cache, Scg.empty)
        | Neg -> (Result.return { nat = prec; br; return }, _cache, Scg.empty)
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
      let r =
        match (res2, res1) with
        | Bot, _ -> Result.Bot
        | _, Bot -> failwith "should be impossible"
        | Def res1, Def res2 ->
            Result.return
              {
                nat = res2.nat;
                br = Labelmap.lub res1.br res2.br;
                return = Memory.join res1.return res2.return;
              }
      in
      (r, cache'', Scg.union scg_h scg_t)
