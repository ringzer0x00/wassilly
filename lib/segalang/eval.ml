type funcs = Command.Funcs.t
type call = Call.t
type stack = Stack.t
type result = Result.t
type partial_result = Result.partial_result
type cache = Cache.t
type scg = Scg.t

let fixpoint _funcs (((_env, _expr) as _call), _ifb) _stack _cache _pres _eval =
  failwith ""

let rec eval (funcs : funcs) (call : call) (_stack : stack) (_cache : cache)
    ({ br; return } as pres : partial_result) : result * cache * scg =
  let prec, prog = call in
  match prog with
  | [] -> failwith ""
  | c1 :: c2 ->
      let res1 : result =
        match c1 with
        | Binop _bop -> { nat = prec; br; return }
        | Unop _uop -> { nat = prec; br; return }
        | Block (_res_arity, _stmt) -> failwith ""
        | _ -> failwith ""
      in
      let res2 =
        fixpoint funcs ((res1.nat, c2), false) _stack _cache pres eval
      in
      failwith "res2.ret U res2.nat ; res2.nat ; res1.jmp U res2.jmp"
