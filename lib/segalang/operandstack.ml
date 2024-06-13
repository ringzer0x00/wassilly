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

(*abstract value operations*)
let lub s1 s2 = List.map2 (fun x y -> Operand.lub x y) s1 s2
let widen s1 s2 = List.map2 (fun x y -> Operand.widen x y) s1 s2
