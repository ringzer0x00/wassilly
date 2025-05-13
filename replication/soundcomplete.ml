open Datastructures.Callgraph.Ga

module Edge = struct
  type t = vertex * vertex

  let compare = compare
end

module Vertex = struct
  type t = vertex

  let compare = compare
end

module EdgesSet = Set.Make (Edge)
module VerticesSet = Set.Make (Vertex)

let sub_edges = EdgesSet.subset
let sub_vertices = VerticesSet.subset

let complete e_an e_gt v_an v_gt : bool =
  (EdgesSet.subset e_an e_gt || EdgesSet.equal e_an e_gt)
  && (VerticesSet.subset v_an v_gt || VerticesSet.equal v_an v_gt)

let sound e_an e_gt v_an v_gt : bool =
  (EdgesSet.subset e_gt e_an || EdgesSet.equal e_gt e_an)
  && (VerticesSet.subset v_gt v_an || VerticesSet.equal v_gt v_an)

let exact e_an e_gt v_an v_gt : bool =
  complete e_an e_gt v_an v_gt && sound e_an e_gt v_an v_gt
