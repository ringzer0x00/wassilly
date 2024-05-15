module type I = Inputoutput.InterpreterInput

module type S = sig
  type e
  type t

  val in_domain : e -> t -> bool
  val add : e -> t -> t * e option
  val widen : e -> t -> t
end

module Stack (I : I) : S = struct
  module S = Set.Make (I)

  type e = I.t
  type t = S.t

  let in_domain elem stack = S.exists (I.pred elem) stack

  let add e s =
    let s' = S.add e s in
    (s', if s' = s then None else Some e)

  let widen _ _ = failwith ""
end
