open Memory

let enter_block bl (prec : t) =
  match prec with
  | Bot -> Bot
  | Def d -> return { vm = d.vm; opsk = d.opsk; lsk = Labelstack.push bl d.lsk }

let end_of_block prec = prec

let const_val _v prec =
  match prec with
  | Bot -> Bot
  | Def d ->
      return
        {
          vm = d.vm;
          lsk = d.lsk;
          opsk = Operandstack.push_ops [ Value.top ] d.opsk;
        }
