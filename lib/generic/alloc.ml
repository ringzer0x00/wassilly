module type GAlloc = sig
  type alloc
  type valtype
  type t

  val mkalloc : string -> alloc -> t
  val type_of_valtype : valtype -> string
  val compare : t -> t -> int
end

module type MapAlloc = GAlloc

module type ApronAlloc = sig
  type alloc = Apron.Var.t
  type valtype
  type t

  val mkalloc : string -> alloc -> t
  val type_of_valtype : valtype -> string
  val to_add : t -> alloc array * alloc array * alloc
  val compare : t -> t -> int
  val var_of_alloc : t -> alloc
end

module VarMapAlloc : MapAlloc = struct
  type alloc = string
  type valtype = Int | Float
  type t = valtype * alloc

  let mkalloc t (n : alloc) : t =
    match t with "int" -> (Int, n) | "float" -> (Float, n) | _ -> failwith ""

  let type_of_valtype = function Int -> "int" | Float -> "float"
  let compare = compare
end

module VarApronAlloc : ApronAlloc = struct
  type alloc = Apron.Var.t
  type valtype = Apron.Environment.typvar
  type t = valtype * alloc

  let mkalloc t (n : alloc) : t =
    match t with "int" -> (INT, n) | "float" -> (REAL, n) | _ -> failwith ""

  let type_of_valtype (a : valtype) =
    match a with INT -> "int" | REAL -> "float"

  let to_add (alloc : t) =
    match alloc with
    | INT, vname -> ([| vname |], [||], vname)
    | REAL, vname -> ([||], [| vname |], vname)

  let var_of_alloc a : alloc = snd a
  let compare = compare
end
