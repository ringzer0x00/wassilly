module Command = Language.Command.Command
module Memory = Memories.Frame

module Stack = struct
  include Map.Make (Command)

  let empty : Memory.t t = empty

  let call_in_stack (env, expr) stack =
    match find_opt expr stack with
    | Some envStack -> env = envStack
    | None -> false

  let expr_in_stack e s = exists (fun xpr _ -> e = xpr) s
end
