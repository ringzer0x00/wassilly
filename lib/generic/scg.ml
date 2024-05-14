module type SCG = sig
  type e
  type t

  val in_domain : e -> t -> bool
  val add : e -> t -> t (*add*)
end

module StronglyConnectedGraph = struct end
