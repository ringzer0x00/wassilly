module type Language = sig
  type l
  type in_
  type out_

  val eval : in_ -> 'a -> 'b -> out_
end
(* I/O *)
