module type Lang = sig
  type l
end

module C (L : Lang) = struct
  type t = L.l

  let compare = compare
end

module Language = struct
  type bexpr = Eq of expr * expr

  and expr =
    | Var of string
    | Num of int
    | Add of expr * expr
    | Sub of expr * expr
    | Mul of expr * expr
    | If of bexpr * expr * expr
    | Call of string * expr list

  type l = expr
end

module Funcs = struct
  include Map.Make (String)

  let empty : (string list * Language.expr) t = empty
end

module Command = struct
  include C (Language)

  let print = function
    | Language.Call (n, _) -> Format.pp_print_string Format.std_formatter n
    | _ -> failwith ""
end
