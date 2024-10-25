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
  let to_list g = S.to_seq g |> List.of_seq

  let print g =
    Format.printf "Callgraph:[";
    S.iter
      (fun (f, t) ->
        Format.printf "%s -> %s\n" (Int32.to_string f) (Int32.to_string t))
      g;
    Format.printf "]\n"

  let edges g =
    S.to_seq g |> List.of_seq
    |> List.map (fun (x, y) -> (Int32.to_int x, Int32.to_int y))
end

module Vertex = struct
  type t = int

  let compare = Stdlib.compare
  let hash = Hashtbl.hash
  let equal = ( = )
end

module Edge = struct
  type t = string

  let compare = Stdlib.compare
  let equal = ( = )
  let default = ""
end

module Ga = struct
  include Graph.Imperative.Digraph.ConcreteBidirectionalLabeled (Vertex) (Edge)

  let phi = create ()
  let add_vertex = add_vertex
  let add_edge = add_edge_e

  let union (g1 : t) (g2 : t) =
    let g_res = phi in
    iter_vertex (fun v -> add_vertex g_res v) g1;
    iter_edges_e (fun e -> add_edge_e g_res e) g1;
    iter_vertex (fun v -> add_vertex g_res v) g2;
    iter_edges_e (fun e -> add_edge_e g_res e) g2
end

module Dot = Graph.Graphviz.Dot (struct
  include Ga (* use the graph module from above *)

  let edge_attributes (_, e, _) = [ `Label e; `Color 4711 ]
  let default_edge_attributes _ = []
  let get_subgraph _ = None
  let vertex_attributes _ = [ `Shape `Box ]
  let vertex_name v = string_of_int v
  let default_vertex_attributes _ = []
  let graph_attributes _ = []
end)

let write_to_file f g =
  let file = open_out_bin f in
  Dot.output_graph file g
