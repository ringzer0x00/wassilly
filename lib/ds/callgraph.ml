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
    let equal = ( = )
    let hash = Hashtbl.hash
  end

  module Int = struct
    type t = int32

    let compare = Stdlib.compare
    let hash = Hashtbl.hash
    let equal = ( = )
    let default = Int32.zero
  end

  include Graph.Persistent.Digraph.ConcreteLabeled (IntInt) (Int)

  let phi = empty

  let union (g1 : t) (g2 : t) =
    let g1' = fold_vertex (fun v g -> add_vertex g v) g2 g1 in
    fold_edges_e (fun v e -> add_edge_e e v) g2 g1'

  let add_vertex = add_vertex
  let add_edge = add_edge_e
end
