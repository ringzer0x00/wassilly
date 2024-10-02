open Call
module Memory = Memories.Memorystate
module Cache = Cache.Cache

let wStack stack ((env1, expr) as call : Call.t) =
  match Stack.Stack.expr_in_stack expr stack with
  | false -> (Stack.Stack.add expr env1 stack, call)
  | true ->
      let env2 = Stack.Stack.find expr stack in
      if Memory.leq env1 env2 then (stack, (env2, expr))
      else
        let envWidened = Memory.widen env2 env1 in
        (Stack.Stack.add expr envWidened stack, (envWidened, expr))

(*let wVal = Memories.Stack.widening (*raw intervals, lets see if it is correct*)*)
let call_in_cache call cache = Cache.call_in_cache call cache

let call_in_stack (env, expr) stack =
  match Stack.Stack.find_opt expr stack with
  | Some envStack -> env = envStack
  | None -> false
