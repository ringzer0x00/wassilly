type init = string
type func = string
type atom = Init of init | Func of func | Word of string
type program = Program of atom list

let dump_atom = function
  | Init s -> "Init " ^ s
  | Func f -> "Func " ^ f
  | Word w -> "Word " ^ w

let dump_program (Program atoms) =
  "[" ^ String.concat ", " (List.map dump_atom atoms) ^ "]"
