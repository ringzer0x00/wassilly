type t = Table.t list

let join a _ =
  Printf.printf "WARNING: NOT IMPLEMENTED JOIN @ TABLES";
  a

let widen a _ =
  Printf.printf "WARNING: NOT IMPLEMENTED WIDEN @ TABLES";
  a

let leq _ _ =
  Printf.printf "WARNING: NOT IMPLEMENTED LEQ @ TABLES";
  true

let eq _ _ =
  Printf.printf "WARNING: NOT IMPLEMENTED EQ @ TABLES";
  true

let lt _ _ =
  Printf.printf "WARNING: NOT IMPLEMENTED LT @ TABLES";
  true
