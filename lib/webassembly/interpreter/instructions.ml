open Memories.Frame
open Memories.Operandstack
open Exprs_math
open Datastructures.Monad.DefBot

(*-- controlflow*)
let enter_block bl prec =
  prec >>= fun d ->
  let ops' = push (bl, d.ops) in
  return { ops = ops'; var = d.var; mem = d.mem; tab = d.tab }

let end_of_block prec =
  prec >>= fun d ->
  return
    { ops = failwith "pop first label"; var = d.var; mem = d.mem; tab = d.tab }

let brpeek prec n = prec >>=? fun d -> peek_nth_label d.ops n

(* -- maths*)
let const_val v prec =
  prec >>= fun d ->
  let ops' = push (const v d.var, d.ops) in
  return { ops = ops'; var = d.var; mem = d.mem; tab = d.tab }

(* -- binops*)
let mul prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> mul_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let divs prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> divs_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let add prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> add_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let sub prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> sub_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

(* -- unops*)
let neg prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> neg_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let sqrt prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> sqrt_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let read prec v =
  prec >>= fun d ->
  let ops' = push (v, d.ops) in
  return { ops = ops'; var = d.var; mem = d.mem; tab = d.tab }

(* -- compare ops*)
let ge_s prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> ge_s_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let gt_s prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> gt_s_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let le_s prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> le_s_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let eq prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x -> eq_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let eqz prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> eqz_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }
