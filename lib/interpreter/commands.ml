(*let rec eval funcs call stack cache =*)
let eval _module (ms, (p : Wasm.Ast.instr list)) _cont _sk _cache =
  match p with
  | [] -> failwith ""
  | h :: t -> (
      let _nat_c = t in
      match h.it with
      | Binary _bop -> Binops.eval_binop _bop ms
      | _ -> failwith "")

(*and fixpoint funcs (((_env, _expr) as call), ifb) stack cache =*)
