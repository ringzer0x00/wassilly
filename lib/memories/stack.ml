module LocalVar = Variablemem.LocalVar
module GlobalVar = Variablemem.GlobalVar

type aval = Apronext.Intervalext.t
type whateverisinlabel

type operand =
  | Value of aval
  | LVarRef of int32
  | GVarRef of int32
  | Label of whateverisinlabel (*placeholder*)

(*| Label*)
type stack = operand list
type t = stack
type varmemories = Variablememories.t

let empty : stack = []
let peek = function h :: _ -> h | [] -> failwith "empty"

let peek_binop = function
  | h :: h2 :: _ -> (h, h2)
  | _ :: [] | [] -> failwith "empty"

let pop = function _ :: t -> t | [] -> failwith "empty"
let push x s = x :: s
let append sp s = sp @ s

let concretize (mem : varmemories) = function
  (*two memories are needed, one for locals and one for globals*)
  | Value a -> a
  | LVarRef i -> GlobalVar.lookup mem.loc i
  | GVarRef i -> GlobalVar.lookup mem.glob i
  | Label _ -> failwith "cannot concretize label"

let replace (s : stack) (op : operand) (v : aval) =
  List.map (fun x -> if x = op then Value v else op) s

let concretize_assignment (s : stack) (mem : varmemories) ref =
  match ref with
  | Value _ | Label _ -> failwith "must be reference"
  | LVarRef _ | GVarRef _ ->
      let v = concretize mem ref in
      replace s ref v

let lub i1 i2 : aval = Apronext.Intervalext.join i1 i2

let widening i1 i2 : aval =
  Apronext.Intervalext.join i1 i2 (*to be replaced with widening*)

let jw_operand (mem1, o1) (mem2, o2) operation =
  (*two memories are needed, one for locals and one for globals*)
  if o1 = o2 then o1
  else
    match (o1, o2) with
    | Value v1, Value v2 -> Value (operation v1 v2)
    | Label i1, Label i2 ->
        if i1 = i2 then Label i1 else failwith "labels must coincide"
    | _ -> Value (operation (concretize mem1 o1) (concretize mem2 o2))

let join (m1, s1) (m2, s2) =
  (*two memories are needed, one for locals and one for globals*)
  List.map2 (fun x y -> jw_operand (m1, x) (m2, y) lub) s1 s2

let widen (m1, s1) (m2, s2) =
  (*two memories are needed, one for locals and one for globals*)
  List.map2 (fun x y -> jw_operand (m1, x) (m2, y) widening) s1 s2
