exception EmptyStack

type t = Operand.t list

(*stack operations*)
let push_ops sp s = sp @ s

let peek_n n s =
  let rec aux s acc n =
    if n = 0 then List.rev acc
    else
      match s with [] -> raise EmptyStack | h :: t -> aux t (h :: acc) (n - 1)
  in
  aux s [] n

let pop_n n s =
  let rec aux s n =
    if n = 0 then s
    else match s with [] -> raise EmptyStack | _ :: t -> aux t (n - 1)
  in
  aux s n

(*semantics*)
let intbool s =
  let operand, s = (peek_n 1 s, pop_n 1 s) in
  let operand = List.nth operand 0 in
  (operand, s)

let unop s f =
  let operand, s = (peek_n 1 s, pop_n 1 s) in
  let operand = List.nth operand 0 in
  let res = f operand in
  push_ops [ res ] s

let binop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 0, List.nth operand 1) in
  let res = f l r in
  push_ops [ res ] s

(*abstract domain operations*)
let lub s1 s2 = List.map2 (fun x y -> Operand.lub x y) s1 s2
let widen s1 s2 = List.map2 (fun x y -> Operand.widen x y) s1 s2
let leq s1 s2 = List.for_all2 (fun fst snd -> Operand.leq fst snd) s1 s2
let eq s1 s2 = List.for_all2 (fun fst snd -> Operand.eq fst snd) s1 s2
let le os1 os2 = leq os1 os2 && not (eq os1 os2)
