module Command = Command.Language
include Map.Make (Command)

type tt = Memory.t t
type t = tt

let empty : t = empty
let expr_in_stack e s = exists (fun xpr _ -> e = xpr) s
