open Call
module Memory = Memories.Memorystate
module Cache = Cache.Cache

let printer = Utilities.Printer.print

let wStack stack ((env1, expr) as call : Call.t) =
  match Stack.Stack.expr_in_stack expr stack with
  | false ->
      printer Format.print_string "expr not in stack, adding body to stack\n";
      (Stack.Stack.add expr env1 stack, call)
  | true ->
      printer Format.print_string "expr in stack, what do i do?\n";
      let env2 = Stack.Stack.find expr stack in
      if Memory.leq env1 env2 then (
        printer Format.print_string "ENV1 LEQ ENV2 -> TRUE\n";
        (stack, (env2, expr)))
      else
        (printer Format.print_string "ENV1 LEQ ENV2 -> FALSE\n";
        let envWidened = Memory.widen env2 env1 in
        (Stack.Stack.add expr envWidened stack, (envWidened, expr)))

(*let wVal = Memories.Stack.widening (*raw intervals, lets see if it is correct*)*)
let call_in_cache call cache = Cache.call_in_cache call cache

let call_in_stack (env, expr) stack =
  match Stack.Stack.find_opt expr stack with
  | Some envStack -> env = envStack
  | None -> false
