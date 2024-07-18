module WackyEdge = struct
  type f = Wasm.Ast.instr
  type to_ = Int32.t
  type t = f * to_

  let compare = compare
  let edge f t : t = (f, t)
  let ( ~> ) = edge
end

module GraphEdge = struct
  type from = Int32.t
  type to_ = Int32.t
  type t = from * to_

  let compare = compare
  let edge f t : t = (f, t)
  let ( ~> ) = edge
end

module CallSet = struct
  module S = Set.Make (WackyEdge)

  type t = S.t

  let phi = S.empty
  let singleton = S.singleton
  let add = S.add
  let union = S.union

  let print g =
    Printf.printf "CallSet:[";
    S.iter
      (fun (f, t) ->
        Printf.printf "%s -> %s\n"
          (Wasm.Source.string_of_region f.at)
          (Int32.to_string t))
      g;
    Printf.printf "]\n"
  (*type pos = {file : string; line : int; column : int}
    type region = {left : pos; right : pos}
    type 'a phrase = {at : region; it : 'a}
    - turn into from-to for functions? *)
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
end

let find_fidx_from_instr (mod_ : Wasm.Ast.module_) (i : Wasm.Ast.instr) =
  let fs =
    mod_.it.funcs
    |> List.mapi (fun i (x : Wasm.Ast.func) -> (Int32.of_int i, x.it.body))
  in
  let f =
    List.find (fun (_fun_idx, body) -> List.exists (fun x -> x = i) body) fs
    |> fst
  in
  f

let cs_to_cg (cs : CallSet.t) mod_ =
  List.map
    (fun (x, y) -> (find_fidx_from_instr mod_ x, y))
    (CallSet.S.elements cs)
  |> CallGraph.of_list
