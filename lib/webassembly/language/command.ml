module Command = struct
  type t = Wasm.Ast.instr list

  let compare = compare
end