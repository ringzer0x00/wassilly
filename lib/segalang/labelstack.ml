exception EmptyStack

type t = Label.t list

let peek_nth nth l = List.nth_opt l nth

let pop_n n s =
  let rec aux s n =
    if n = 0 then s
    else match s with [] -> raise EmptyStack | _ :: t -> aux t (n - 1)
  in
  aux s n

let push x s : t = x :: s
let is_empty = function [] -> true | _ -> false
