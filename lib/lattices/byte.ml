module Byte : Lattice.L = struct
  module B = Bitfield.BFLattice

  type t = B.t array
  type env = B.env
  type man = B.man

  let mgr = B.mgr
  let top () = Array.init 8 B.top
  let bottom () = Array.init 8 B.bottom
  let lub b1 b2 = Array.map2 (fun fst snd -> B.lub fst snd) b1 b2
  let widen = lub
  let meet _ _ = failwith "you cant meet me apparently @ Byte"
  (*if any here is bottom, all is bottom (all is glorzo, glory to glorzo)*)

  let partialOrder b1 b2 =
    Array.for_all2 (fun fst snd -> B.partialOrder fst snd) b1 b2

  let toString b =
    Array.map (fun x -> B.toString x) b |> Array.to_list |> String.concat "|"

  let print b = toString b |> print_string
end
