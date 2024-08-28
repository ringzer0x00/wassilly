open Memories.Memorystate
open Memories.Operand
open Memories.Operandstack
open Exprs_math
open Datastructures.Monad.DefBot

type wn = Wasm.Types.num_type

(*-- controlflow*)
let end_of_block prec mod_ =
  prec >>= fun d ->
  let _, _t =
    match peek_nth_label d.ops 0 with
    | Some (Label l) ->
        Memories.Label.type_of_peeked_label l
        |> Memories.Label.extract_type_of_label mod_
    | _ -> failwith "cannot handle"
  in
  let _vals, ops' =
    (peek_n (List.length _t) d.ops, pop_n (List.length _t) d.ops)
  in
  Printf.printf "_t length: %i, d.ops: %i" (List.length _t) (List.length d.ops);
  let prec' =
    return
      (*peek first label, discover type and blabla*)
      { ops = ops'; var = d.var; mem = d.mem; tab = d.tab }
  in
  let prec'' = Memories.Memorystate.pop_n_labels prec' 1 in
  Memories.Memorystate.push_operand _vals prec''

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
  let divisor = concretize d.var (peek d.ops) in
  match Apronext.Intervalext.equal_int divisor 0 with
  | true -> Bot
  | false ->
      let opsk' = binop d.ops (fun x y -> divs_expr d.var x y) |> push in
      return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let rems prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> rems_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let add prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> add_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let sub prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> sub_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let l_and prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> land_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let l_or prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> lor_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let l_xor prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> lxor_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let l_shift prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> lshift_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let shift_stub prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> shift_stub_expr d.var x y) |> push in
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

let abs prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> abs_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let ceil prec =
  prec >>= fun d ->
  let opsk' =
    unop d.ops (fun x -> round d.var x Apronext.Texprext.Up) |> push
  in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let floor prec =
  prec >>= fun d ->
  let opsk' =
    unop d.ops (fun x -> round d.var x Apronext.Texprext.Down) |> push
  in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let nearest prec =
  prec >>= fun d ->
  let opsk' =
    unop d.ops (fun x -> round d.var x Apronext.Texprext.Near) |> push
  in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let trunc prec =
  prec >>= fun d ->
  let opsk' =
    unop d.ops (fun x -> round d.var x Apronext.Texprext.Zero) |> push
  in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let popcnt prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> popcnt_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let clz prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> clz_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let ctz prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> ctz_expr d.var x) |> push in
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

let lt_s prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> lt_s_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let le_s prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x y -> le_s_expr d.var x y) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let eq prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x -> eq_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let ne prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x -> ne_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let cmpstub prec =
  prec >>= fun d ->
  let opsk' = binop d.ops (fun x -> cmpstub_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let eqz prec =
  prec >>= fun d ->
  let opsk' = unop d.ops (fun x -> eqz_expr d.var x) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

(*conversion*)
let extend_s_i32 prec =
  prec >>= fun d ->
  let opsk' = cvtop d.ops (fun x -> convert_extend d.var x I64Type) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let demote_f64 prec =
  prec >>= fun d ->
  let opsk' = cvtop d.ops (fun x -> demote d.var x F32Type) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }

let extend_u_i32 _prec = failwith "extend unsign"

(*memory ops*)
let load_i32 prec =
  prec >>= fun d ->(* vm _mem _lm _o *)
  let opsk' = unop d.ops (fun x -> load_i32 d.var d.mem x Wasm.Types.I32Type) |> push in
  return { ops = opsk'; var = d.var; mem = d.mem; tab = d.tab }
