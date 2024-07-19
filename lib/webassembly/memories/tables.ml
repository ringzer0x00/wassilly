type t = Table.t list

let join a _ = a
let widen a _ = a
let leq _ _ = Printf.printf "WARNING: NOT IMPLEMENTED LEQ @ TABLES"; true
let eq _ _ = Printf.printf "WARNING: NOT IMPLEMENTED EQ @ TABLES"; true
let lt _ _ = Printf.printf "WARNING: NOT IMPLEMENTED LT @ TABLES"; true