type funcs = Command.Funcs.t
type call = Call.t
type stack = Stack.t
type result = Result.t
type cache = Cache.t
type scg = Scg.t

let _fixpoint _funcs (((_env, _expr) as _call), _ifb) _stack _cache =
  failwith ""

let eval (funcs: funcs) (call:call) (_stack:stack) (_cache:cache) : result * cache * scg =
  let prec, prog = call in
  failwith ""
