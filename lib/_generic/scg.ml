module type SCG = sig
  type e
  type t

  val add : e -> t -> t
  val remove : e -> t -> t
end

module StronglyConnectedGraph (E : Inputoutput.InterpreterInput) : SCG = struct
  type e = E.t

  module S = Set.Make (E)

  type t = S.t

  let add e s = S.add e s
  let remove e s = S.remove e s
end
