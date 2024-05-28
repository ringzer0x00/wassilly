type t = {
  ctx : Context.t;
  var : Variablememories.t;
  mem : Linearmem.t;
  tab : Tables.t;
}

let pop ms =
  { ctx = Context.pop_operand ms.ctx; var = ms.var; mem = ms.mem; tab = ms.tab }

let pop_n _n = failwith "todo"
let peek ms = Context.peek_operand ms.ctx
let peek_binop ms = Context.peek_binop ms.ctx

let join ms1 ms2 =
  {
    ctx = Context.join  ms1.ctx ms2.ctx;
    var = Variablememories.join ms1.var ms2.var;
    mem = Linearmem.join ms1.mem ms2.mem;
    tab = Tables.join ms1.tab ms2.tab;
  }

let widen ms1 ms2 =
  {
    ctx = Context.widen ms1.ctx ms2.ctx;
    var = Variablememories.widen ms1.var ms2.var;
    mem = Linearmem.widen ms1.mem ms2.mem;
    tab = Tables.widen ms1.tab ms2.tab;
  }

let filter_loc ms c =
  {
    ctx = ms.ctx;
    var = Variablememories.filter_loc ms.var c;
    mem = ms.mem;
    tab = ms.tab;
  }

let filter_glob ms c =
  {
    ctx = ms.ctx;
    var = Variablememories.filter_glob ms.var c;
    mem = ms.mem;
    tab = ms.tab;
  }

(*ms1 <= ms2*)
let leq ms1 ms2 =
  Context.leq (ms1.ctx) (ms2.ctx)
  && Variablememories.leq ms1.var ms2.var
  && Linearmem.leq ms1.mem ms2.mem
  && Tables.leq ms1.tab ms2.tab

(*ms1 = ms2*)
let eq ms1 ms2 =
  Context.eq (ms1.ctx) (ms2.ctx)
  && Variablememories.eq ms1.var ms2.var
  && Linearmem.eq ms1.mem ms2.mem
  && Tables.eq ms1.tab ms2.tab

(*ms1 < ms2 *)
let lt ms1 ms2 = leq ms1 ms2 && not (eq ms1 ms2)
