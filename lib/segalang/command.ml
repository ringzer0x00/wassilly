module Language = struct
  type bop = int32 -> int32 -> int32
  type uop = int32 -> int32
  type fid = string
  type var = string
  type label = string

  type stmt = cmd list

  and cmd =
    | Block of label * stmt
    | Loop of label * stmt
    | MemRead of var
    | MemWrite of var
    | Val of int32
    | Binop of bop
    | Unop of uop
    | If of stmt * stmt
    | Call of fid
    | Br of label
end
