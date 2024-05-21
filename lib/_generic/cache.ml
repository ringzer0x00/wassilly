module type I = Inputoutput.InterpreterInput
module type CD = Cacheddata.CD

module type C = sig
  type k
  type d
  type t

  val empty : t
  val add : k -> d -> t -> t
  val lookup : k -> t -> d option
end

module Cache (D : CD) (K : I) : C = struct
  type k = K.t
  type d = D.t

  module M = Datastructures.Mapping.Make (K) (D)

  type t = M.t

  let empty : t = M.empty
  let add k d m : t = M.add k d m
  let find_opt k m : d option = M.find_opt k m
  let lookup = find_opt
end
