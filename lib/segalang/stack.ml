module Command = Command.Language
module Memory = Memory.Memory

module Stack = struct
  include Map.Make (Command)

  let empty : Memory.t t = empty
  let expr_in_stack e s = exists (fun xpr _ -> e = xpr) s

  let print (m : Memory.t t) =
    iter
      (fun _k v ->
        Format.print_string "fib:";
        Memory.print v)
      m
end
