(*open Chaotic_implicitgraph
  open Command

  let body =
    Language.If
      ( Language.Eq (Var "loc", Num 0),
        Num 0,
        Language.If
          ( Language.Eq (Var "loc", Num 1),
            Num 1,
            Language.Add
              ( Language.Call ("fib", [ Sub (Var "loc", Num 1) ]),
                Language.Call ("fib", [ Sub (Var "loc", Num 2) ]) ) ) )

  let env =
    Memory.Memory.add "loc"
      (Value.Val (Value.Int 1, Value.PInf))
      (Memory.Memory.make_empty Eval.mgr)

  let funs = Funcs.add "fib" ([ "loc" ], body) Funcs.empty

  let () =
    let r, _, _ =
      Eval.eval funs (env, body) Stack.Stack.empty Cache.Cache.empty
    in
    Format.print_string ("\n\nRESULT:" ^ Value.to_string r)
*)
