type 'a t = Def of 'a | Bot

(*monadic operators*)
let return x = Def x

let bind (x, y) op =
  match (x, y) with
  | Bot, Bot -> Bot
  | Def a, Bot | Bot, Def a -> return a
  | Def a, Def b -> op a b

let ( >>= ) = bind
let id x = x
