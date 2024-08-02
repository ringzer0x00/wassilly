module Memory = Memory
module Cache = Cache

let wStack stack ((env1, expr) as call : Call.t) =
  match Stack.expr_in_stack expr stack with
  | false ->
      Format.print_string "expression not in stack\n";
      Format.print_flush ();
      (Stack.add expr env1 stack, call)
  | true ->
      let env2 = Stack.find expr stack in
      if Memory.leq env1 env2 then (
        Format.print_string "env in stack is bigger\n";
        Format.print_flush ();
        (stack, (env2, expr)))
      else (
        Format.print_string "env in stack is smaller, widening\n";
        Format.print_flush ();
        let envWidened = Memory.widen env2 env1 in
        (Stack.add expr envWidened stack, (envWidened, expr)))

(*let wVal = Memories.Stack.widening (*raw intervals, lets see if it is correct*)*)
let call_in_cache call cache = Cache.call_in_cache call cache

let call_in_stack (env, expr) stack =
  match Stack.find_opt expr stack with
  | Some envStack -> env = envStack
  | None -> false
