open Memory

let enter_block bl (prec : t) =
  match prec with
  | Bot -> Bot
  | Def d -> return { vm = d.vm; opsk = d.opsk; lsk = Labelstack.push bl d.lsk }

let end_of_block prec = prec
