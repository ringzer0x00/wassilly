type 'a t = Def of 'a | Bot

let return x = Def x
let bind x op = match x with Bot -> Bot | Def a -> op a
let ( >>= ) = bind
let compose f g x = f x >>= fun y -> g y
let ( >=> ) = compose
let map x f = x >>= fun d -> f d
