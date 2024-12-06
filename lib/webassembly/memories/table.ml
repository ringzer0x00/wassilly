module Func = struct
  type t = Int32.t option * Int32.t option (*funcidx , type*)

  let compare = compare
end

let ( ++ ) = Int32.add

module T = Datastructures.Mapping.Make (Int32) (Func)

type t = T.t

let empty = T.empty
let add idx v t : t = T.add idx v t
let set (i, v) t = add i v t
let get _ _ = failwith "table set not available yet"
let find_by_types typ_ t = T.filter (fun _ (_, mapped_t) -> mapped_t = typ_) t

let find_by_idx (intval : Apron.Interval.t) t =
  if Apronext.Intervalext.is_top intval then t
  else if Apronext.Intervalext.is_bottom intval then T.empty
  else
    let i, s = Apronext.Intervalext.to_float intval in
    let funmin, funmax = (Int32.of_float i, Int32.of_float s) in
    T.filter (fun i _ -> i >= funmin && i <= funmax) t
