type t = Abstractbit.t array

let def_init = Abstractbit.Zero
let alloc_byte : t = Array.make 8 def_init
let join b1 b2 = Array.map2 (fun fst snd -> Abstractbit.lub fst snd) b1 b2
let widen = join

let byte_leq b1 b2 =
  Array.for_all2 (fun fst snd -> Abstractbit.leq fst snd) b1 b2

let byte_eq b1 b2 = Array.for_all2 (fun fst snd -> Abstractbit.eq fst snd) b1 b2

let byte_le b1 b2 =
  Array.for_all2
    (fun fst snd -> Abstractbit.leq fst snd && not (Abstractbit.eq fst snd))
    b1 b2
