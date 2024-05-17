open Apron

let new_mgr mgr =
  let m =
    match mgr with
    | "polystrict" -> Polka.manager_alloc_strict () |> Polka.manager_of_polka
    (*| "interval" -> Box.manager_alloc () |> Box.manager_of_box*)
    | _ -> failwith "alloc"
  in
  m

let new_aenv int real = Environment.make int real
let new_memory m env = Abstract1.top m env
let join mgr m1 m2 = Abstract1.join mgr m1 m2
let widening mgr m1 m2 = Abstract1.widening mgr m1 m2
