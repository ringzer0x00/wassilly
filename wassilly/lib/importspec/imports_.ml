type mem_id = int32 (*idx o string?*)
type table_id = int32 (*idx o string?*)
type pos = int32
type name = string
type called = int32 list
(*~~~*)

type value = string (*interval*)
type binop = Mul | Sub | Mod | Add | Div
type unop = Sqrt

type expr =
  | Val of value
  | Binop of binop * expr * expr
  | Unop of unop * expr
  | Top
  | Bot

type comparison = Lt | Gt | Eq | LtE | GtE
type constraint_ = Comparison of comparison * expr * expr

(* identificatore + valore, unspecified è T *)
type assignment =
  | Glob of { n : name; v : expr }
  | Mem of { m : mem_id; v : (pos * expr) list }
  | Table of { t : table_id; v : (pos * expr) list }

type cond = constraint_ list

(*
  - r: vector of expressions
  - c: calls
  - e: effects -> assignments.
    unspecified assignments will assume as "unchanged"
*)
type res = { r : expr list; c : called; e : assignment list }
and func_spec = With of { c : cond; t : res; e : func_spec }

type spec = Init of assignment list | Func of { n : name; f : func_spec }
