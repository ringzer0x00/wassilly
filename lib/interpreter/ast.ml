open Wasm.Ast

type t = Wasm.Ast.var

let var i = match i with LocalGet i -> i.it | _ -> failwith ""
