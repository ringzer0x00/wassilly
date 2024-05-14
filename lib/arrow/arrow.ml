(*module type SIMPLE_ARROW = sig
    type ('a, 'b) t

    val arr : ('a -> 'b) -> ('a, 'b) t
    val ( >>> ) : ('a, 'b) t -> ('b, 'c) t -> ('a, 'c) t
    val app : unit -> (('a, 'b) t * 'a, 'b) t
    val run : ('a, 'b) t -> 'a -> 'b
  end*)

module SimpleArrow = struct
  type ('a, 'b) t = 'a -> 'b

  let arr f = f
  let ( >>> ) f g x = g (f x)
  let app () (f, x) = f x
  let ( -< ) f x = app () (f, x)
  let run = arr
end

let f = SimpleArrow.arr (Int.add 1)
let ran = SimpleArrow.run f 1
let conc = SimpleArrow.( >>> ) f (SimpleArrow.arr (Int.add 1))
let r = SimpleArrow.run conc 1
let ( -< ) f x = SimpleArrow.app () (f, x)
let boh = f -< SimpleArrow.arr 1
let return x = Some x

let addA f g x =
  let y = f -< x in
  let z = g -< x in
  y + z

let pippo =
  let f = SimpleArrow.arr (Int.add 1) in
  let g = SimpleArrow.arr (Int.add 2) in
  addA f g (*manca l'espressione a cui applicare la computazione*)
