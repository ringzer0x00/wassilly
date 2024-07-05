open Memories.Frame
open Memories.Operandstack
module LS = Memories.Labelstack
open Exprs_math
(*{
    ops : Memories.Operandstack.t;
    var : Memories.Variablememory.t;
    mem : Memories.Linearmem.t;
    tab : Memories.Tables.t;
    lsk : Memories.Labelstack.t;
  }*)

let enter_block bl prec =
  prec >>= fun d ->
  return
    {
      ops = d.ops;
      var = d.var;
      mem = d.mem;
      tab = d.tab;
      lsk = LS.push bl d.lsk;
    }

let end_of_block prec =
  prec >>= fun d ->
  return
    {
      ops = d.ops;
      var = d.var;
      mem = d.mem;
      tab = d.tab;
      lsk = (if LS.is_empty d.lsk then d.lsk else LS.pop_n 1 d.lsk);
    }

let br prec depth =
  prec >>= fun d ->
  return
    {
      ops = d.ops;
      var = d.var;
      mem = d.mem;
      tab = d.tab;
      lsk =
        (if LS.is_empty d.lsk then raise LS.EmptyStack
         else LS.pop_n (depth + 1) d.lsk);
    }

let brpeek prec n =
  match prec with Bot -> raise LS.EmptyStack | Def d -> LS.peek_nth n d.lsk

let const_val v prec =
  prec >>= fun d ->
  return
    {
      ops = (fun v sk -> append (const v d.var) sk) v d.ops;
      var = d.var;
      mem = d.mem;
      tab = d.tab;
      lsk = d.lsk;
    }

let mul prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> mul_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }

let divs prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> divs_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }

let add prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> add_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }

let sub prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> sub_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }

let neg prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> neg_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }

let read prec v =
  prec >>= fun d ->
  let ops' = push (v, d.ops) in
  return { ops = ops'; var = d.var; mem = d.mem; tab = d.tab; lsk = d.lsk }
