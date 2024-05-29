exception EmptyStack

type 'a stack = 'a list

let peek = function h :: _ -> h | [] -> raise EmptyStack
let peekn _n _ = failwith ""
let pop = function _ :: t -> t | [] -> raise EmptyStack
let popn _n _ = failwith ""
let push x l = x :: l
let push_vec x l = x @ l
let update_topmost h' = function [] -> raise EmptyStack | _ :: t -> h' :: t

let pop_n n s =
  let rec aux s n =
    if n = 0 then s
    else match s with [] -> raise EmptyStack | _ :: t -> aux t (n - 1)
  in
  aux s n

let peek_n n s =
  let rec aux s acc n =
    if n = 0 then List.rev acc
    else
      match s with [] -> raise EmptyStack | h :: t -> aux t (h :: acc) (n - 1)
  in
  aux s [] n
