module MS = Memories.Memorystate

type module_ = Wasm.Ast.module_ (*or ' (?)*)

(*let rec eval funcs call stack cache =*)
let eval _module ((ms : MS.t), (p : Wasm.Ast.instr list)) _cont _sk _cache =
  match p with
  | [] -> failwith ""
  | h :: t ->
      let _nat_c = t in
      let (_ms' : MS.t), _funscalled_to_become_set =
        match h.it with
        | Binary _bop -> (Binops.eval_binop _bop ms, None)
        | Unary _uop -> (Unops.eval_unop _uop ms, None)
        | Drop -> (MS.pop ms, None)
        | Nop -> (ms, None)
        | _ -> failwith ""
      in
      failwith ""

(*and fixpoint funcs (((_env, _expr) as call), ifb) stack cache =*)
