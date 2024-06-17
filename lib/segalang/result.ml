type mem = Memory.t
type lmap = Labelmap.t
type t = { nat : mem; br : lmap; return : mem }
type partial_result = { br : lmap; return : mem }

let pres_of_result (r : t) = { br = r.br; return = r.return }

let join r1 r2 =
  {
    return = Memory.join r1.return r2.return;
    br = Labelmap.lub r1.br r2.br;
    nat = Memory.join r1.nat r2.nat;
  }

let widen r1 r2 =
  {
    return = Memory.widen r1.return r2.return;
    br = Labelmap.widen r1.br r2.br;
    nat = Memory.widen r1.nat r2.nat;
  }
