open Result

let bind x op = match x with Bot -> Bot | Def a -> op a
let ( >>= ) = bind

(*result of sequence*)
let seq_result r1 r2 =
  r1 >>= fun res1 ->
  r2 >>= fun res2 ->
  return
    {
      nat = res2.nat;
      br = Labelmap.lub res1.br res2.br;
      return = Memory.join res1.return res2.return;
    }

(*result of bloc*)
let block_result r_b block_body =
  r_b >>= fun r ->
  return
    {
      nat = Memory.join r.nat (Labelmap.res_label block_body r.br);
      br = Labelmap.remove block_body r.br;
      return = r.return;
    }

(*result of simplecmd*)
let simplecmd_result r pres =
  return { nat = r; br = pres.br; return = pres.return }