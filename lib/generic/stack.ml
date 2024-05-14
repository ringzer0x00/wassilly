module type I = Inputoutput.InterpreterInput

module type S = sig
  type e
  type t

  val in_domain : e -> t -> bool
  (*add*)
end

module Stack (I : I) : S = struct
  module S = Set.Make (I)
  type e = I.t
  type t = S.t

  let in_domain elem stack = S.exists (I.pred elem) stack
  (*add*)
end
