module SK = Datastructures.Liststack
module VariableMem = Variablemem.VariableMem
open Operand

(*| Label*)
type t = operand list
type varmemories = VariableMem.t

let print_stack s =
  Printf.printf "[";
  List.iter (fun x -> print_operand x) s;
  Printf.printf "]\n"

let empty : t = []
let peek_n = SK.peek_n
let pop_n = SK.pop_n
let pop = function _ :: t -> t | [] -> failwith "empty"
let push (x, s) = x :: s
let append sp s = sp @ s
let push_ops = append
let lsk s = List.filter Operand.is_label s
let peek_nth_label s nth = List.nth_opt (lsk s) nth

let concretize_assignment (s : t) (mem : varmemories) (ref : operand) =
  List.map (fun x -> Operand.repl x ref mem) s

let concretize_ret (s : t) (mem : varmemories) =
  let global_bs =
    VariableMem.M.bindings mem.glob
    |> List.map (fun x ->
           let b = fst x in
           Operand.GVarRef (b, b.t))
  in
  let rec concretize_gref stack gbindings =
    match gbindings with
    | [] -> stack
    | h :: t ->
        let stack' = concretize_assignment stack mem h in
        concretize_gref stack' t
  in
  concretize_gref s global_bs

let ival_join i1 i2 : Apronext.Intervalext.t = Apronext.Intervalext.join i1 i2

let ival_widen (smaller : Apron.Interval.t) (bigger : Apron.Interval.t) =
  if not (Apron.Interval.is_leq smaller bigger) then ival_join smaller bigger
  else
    let (smaller_l, smaller_u), (bigger_l, bigger_u) =
      ((smaller.inf, smaller.sup), (bigger.inf, bigger.sup))
    in
    let lower' =
      if bigger_l < smaller_l then Apron.Scalar.of_infty (-1) else bigger_l
    in
    let upper' =
      if bigger_u > smaller_u then Apron.Scalar.of_infty 1 else bigger_u
    in
    Apron.Interval.of_scalar lower' upper'

let join (m1, s1) (m2, s2) =
  Printf.printf "Joining: %i, %i\n" (List.length s1) (List.length s2);
  List.map2 (fun x y -> Operand.jw_operand (m1, x) (m2, y) ival_join) s1 s2

let widen (m1, s1) (m2, s2) =
  Printf.printf "Widening: %i, %i\n" (List.length s1) (List.length s2);
  List.map2 (fun x y -> Operand.jw_operand (m1, x) (m2, y) ival_widen) s1 s2

let leq (m1, s1) (m2, s2) =
  VariableMem.leq m1 m2
  && List.for_all2 (fun fst snd -> Operand.leq_operand m1 fst m2 snd) s1 s2

let eq (m1, s1) (m2, s2) =
  VariableMem.eq m1 m2
  && List.for_all2 (fun fst snd -> Operand.eq_operand m1 fst m2 snd) s1 s2

let le os1 os2 = leq os1 os2 && not (eq os1 os2)

let unop s f =
  let operand, s = (peek_n 1 s |> List.hd, pop_n 1 s) in
  let res = f operand in
  (res, s)

let cvtop s f =
  let operand, s = (peek_n 1 s |> List.hd, pop_n 1 s) in
  let res = f operand in
  (res, s)

let binop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 1, List.nth operand 0) in
  let res = f l r in
  (res, s)

let cmpop s f =
  let operand, s = (peek_n 2 s, pop_n 2 s) in
  let l, r = (List.nth operand 1, List.nth operand 0) in
  let res = f l r in
  (res, s)
