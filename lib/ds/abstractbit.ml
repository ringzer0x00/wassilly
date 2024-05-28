type t = Zero | One | Bot | Top

(*put here bit operations*)

let lub b1 b2 =
  match (b1, b2) with
  | _, Top | Top, _ -> Top
  | Zero, One | One, Zero -> Top
  | Bot, One | One, Bot -> One
  | Bot, Zero | Zero, Bot -> Zero
  | Zero, Zero -> Zero
  | One, One -> One
  | Bot, Bot -> Bot

let widen = lub
let eq b1 b2 = b1 = b2

let leq b1 b2 =
  match (b1, b2) with
  | Zero, Zero | One, One -> true
  | Zero, One | One, Zero -> false
  | Bot, _ -> true
  | _, Bot -> false
  | Top, _ -> false
  | _, Top -> true

let le b1 b2 = leq b1 b2 && not (eq b1 b2)
