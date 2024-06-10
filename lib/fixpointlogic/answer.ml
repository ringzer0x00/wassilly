module MS = Memories.Frame
module LM = Labelmap.LabelMap

(*jmp map label(corpo) -> MS*)
type t = { nat : MS.t; jmp : MS.t; ret : MS.t }

let bot : t = { nat = MS.bot; jmp = MS.bot; ret = MS.bot }

let widen a1 a2 =
  {
    nat = MS.widen a1.nat a2.nat;
    jmp = MS.widen a1.jmp a2.jmp;
    ret = MS.widen a1.ret a2.ret;
  }

let lub a1 a2 =
  {
    nat = MS.join a1.nat a2.nat;
    jmp = MS.join a1.jmp a2.jmp;
    ret = MS.join a1.ret a2.ret;
  }

let leq a1 a2 =
  MS.leq a1.nat a2.nat && MS.leq a1.jmp a2.jmp && MS.leq a1.ret a2.ret

let eq a1 a2 = MS.eq a1.nat a2.nat && MS.eq a1.jmp a2.jmp && MS.eq a1.ret a2.ret
let le a1 a2 = leq a1 a2 && not (eq a1 a2)
