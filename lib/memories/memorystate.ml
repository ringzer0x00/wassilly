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

let included _ _ = failwith ""