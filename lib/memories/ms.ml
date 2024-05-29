(*type t = Context.t

  let join ms1 ms2 =
    {
      ctx = Context.join ms1.ctx ms2.ctx;
      mem = Linearmem.join ms1.mem ms2.mem;
      tab = Tables.join ms1.tab ms2.tab;
    }

  let widen ms1 ms2 =
    {
      ctx = Context.widen ms1.ctx ms2.ctx;
      mem = Linearmem.widen ms1.mem ms2.mem;
      tab = Tables.widen ms1.tab ms2.tab;
    }

  (*ms1 <= ms2*)
  let leq ms1 ms2 =
    Context.leq ms1.ctx ms2.ctx
    && Linearmem.leq ms1.mem ms2.mem
    && Tables.leq ms1.tab ms2.tab

  (*ms1 = ms2*)
  let eq ms1 ms2 =
    Context.eq ms1.ctx ms2.ctx
    && Linearmem.eq ms1.mem ms2.mem
    && Tables.eq ms1.tab ms2.tab

  (*ms1 < ms2 *)
  let lt ms1 ms2 = leq ms1 ms2 && not (eq ms1 ms2)
*)
