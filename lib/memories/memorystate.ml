type t = {
  stk : Stack.t;
  var : Variablememories.t;
  mem : Linearmem.t;
  tab : Tables.t;
}

let pop ms =
  { stk = Stack.pop ms.stk; var = ms.var; mem = ms.mem; tab = ms.tab }

let pop_n _n = failwith "todo"
let peek ms = Stack.peek ms.stk
let peek_binop ms = Stack.peek_binop ms.stk

let join ms1 ms2 =
  {
    stk = Stack.join (ms1.var, ms1.stk) (ms2.var, ms2.stk);
    var = Variablememories.join ms1.var ms2.var;
    mem = Linearmem.join ms1.mem ms2.mem;
    tab = Tables.join ms1.tab ms2.tab;
  }

let widen ms1 ms2 =
  {
    stk = Stack.widen (ms1.var, ms1.stk) (ms2.var, ms2.stk);
    var = Variablememories.widen ms1.var ms2.var;
    mem = Linearmem.widen ms1.mem ms2.mem;
    tab = Tables.widen ms1.tab ms2.tab;
  }

let filter_loc ms c =
  {
    stk = ms.stk;
    var = Variablememories.filter_loc ms.var c;
    mem = ms.mem;
    tab = ms.tab;
  }

let filter_glob ms c =
  {
    stk = ms.stk;
    var = Variablememories.filter_glob ms.var c;
    mem = ms.mem;
    tab = ms.tab;
  }

(*ms1 <= ms2*)
let leq ms1 ms2 =
  Stack.leq (ms1.mem, ms1.stk) (ms2.mem, ms2.stk)
  && Variablememories.leq ms1.var ms2.var
  && Linearmem.leq ms1.mem ms2.mem
  && Tables.leq ms1.tab ms2.tab

(*ms1 = ms2*)
let eq ms1 ms2 =
  Stack.eq (ms1.mem, ms1.stk) (ms2.mem, ms2.stk)
  && Variablememories.eq ms1.var ms2.var
  && Linearmem.eq ms1.mem ms2.mem
  && Tables.eq ms1.tab ms2.tab

(*ms1 < ms2 *)
let lt ms1 ms2 = leq ms1 ms2 && not (eq ms1 ms2)
