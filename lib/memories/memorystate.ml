type t = {
  stk : Stack.t;
  var : Variablememories.t;
  mem : Linearmem.t;
  tab : Tables.t;
}

let join ms1 ms2 =
  {
    stk = Stack.join (ms1.var, ms1.stk) (ms2.var, ms2.stk);
    var = Variablememories.join ms1.var ms2.var;
    mem = Linearmem.join ms1.mem ms2.mem;
    tab = Tables.join ms1.tab ms2.tab;
  }

let widen ms1 ms2 =   {
  stk = Stack.widen (ms1.var, ms1.stk) (ms2.var, ms2.stk);
  var = Variablememories.widen ms1.var ms2.var;
  mem = Linearmem.widen ms1.mem ms2.mem;
  tab = Tables.widen ms1.tab ms2.tab;
}
let filter_globalvar = failwith ""
let filter_localvar = failwith ""
