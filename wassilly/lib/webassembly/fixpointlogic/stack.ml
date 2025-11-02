module Command = Language.Command.Command
module Memory = Memories.Memorystate

module Stack = struct
  include Map.Make (Command)

  let empty : Memory.t t = empty

  let call_in_stack (env, expr) stack =
    match find_opt expr stack with
    | Some envStack -> Memory.leq env envStack (* env = envStack*)
    | None -> false

  let expr_in_stack e s =
    exists
      (fun xpr _ ->
        (*if List.equal (fun a b -> a = b) e xpr then true else false*) e = xpr)
      s
end
