module GraphEdge = struct
  type from = Int32.t
  type to_ = Int32.t
  type t = from * to_

  let compare = compare
  let edge f t : t = (f, t)
  let ( ~> ) = edge
end

module CallGraph = struct
  module S = Set.Make (GraphEdge)

  type t = S.t

  let phi = S.empty
  let singleton = S.singleton
  let add = S.add
  let union = S.union
  let of_list = S.of_list

  let print g =
    Printf.printf "Callgraph:[";
    S.iter
      (fun (f, t) ->
        Printf.printf "%s -> %s\n" (Int32.to_string f) (Int32.to_string t))
      g;
    Printf.printf "]\n"

  let edges g =
    S.to_seq g |> List.of_seq
    |> List.map (fun (x, y) -> (Int32.to_int x, Int32.to_int y))
end

module G = struct

  module IntInt = struct
    type t = int32 * int32
    let compare = Stdlib.compare
    let equal = (=)
    let hash = Hashtbl.hash
  end
  module Int = struct
    type t = int32
    let compare = Stdlib.compare
    let hash = Hashtbl.hash
    let equal = (=)
    let default = Int32.zero
  end

  include Graph.Imperative.Digraph.ConcreteLabeled(IntInt)(Int)

end
