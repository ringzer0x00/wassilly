(* an instance of a wasm module contains the "running" module strucutre:
   funcs -> | ImportedFuncSpec of .. | FuncBody
   globs -> | ImportedGlobSpec of .. | Glob
   mems -> | ImportedMemSpec of .. | Mem
   tables -> | ImportedTableSpec of .. | Table
*)
type spec = string * string

(* -- *)
type definedFunc = Wasm.Ast.func
type definedGlob = Wasm.Ast.global
type memInst = Linearmem.t
type tableInst = Table.t

(* -- *)
type func = Func of definedFunc | ImportedFunc of spec
type glob = Glob of Wasm.Ast.global | ImportedGlob of Wasm.Types.global_type
type table = Table of Wasm.Ast.table | ImportedTable of Wasm.Types.table_type
type mem = Memory of Wasm.Ast.memory | ImportedMemory of Wasm.Types.memory_type

type impordesc = Wasm.Ast.import_desc'

(*--*)
type mod_ = Wasm.Ast.module_

type instance = {
  types : Wasm.Ast.type_ list;
  funcs : func list;
  elems : Wasm.Ast.elem_segment list;
  datas : Wasm.Ast.data_segment list;
  exports : Wasm.Ast.export list;
      (*exports : export list; ~ maybe functions should be tagged?*)
}

(*
let imported_globs (i : Wasm.Ast.import list) =
  let filter (x : Wasm.Ast.import) =
    match x.it.idesc.it with GlobalImport _ -> true | _ -> false
  in
  List.filter filter i
  |> List.map (fun (_x : Wasm.Ast.import) -> ImportedGlob ("name", "TOP"))

let imported_mems (i : Wasm.Ast.import list) =
  let filter (x : Wasm.Ast.import) =
    match x.it.idesc.it with MemoryImport _ -> true | _ -> false
  in
  List.filter filter i
  |> List.map (fun (_x : Wasm.Ast.import) -> ImportedMem ("name", "TOP"))

let imported_tables (i : Wasm.Ast.import list) =
  let filter (x : Wasm.Ast.import) =
    match x.it.idesc.it with TableImport _ -> true | _ -> false
  in
  List.filter filter i
  |> List.map (fun (_x : Wasm.Ast.import) -> ImportedTable ("name", "TOP"))
*)
let imported_funcs (i : Wasm.Ast.import list) =
  let filter (x : Wasm.Ast.import) =
    match x.it.idesc.it with FuncImport _ -> true | _ -> false
  in
  List.filter filter i
  |> List.map (fun (_x : Wasm.Ast.import) -> ImportedFunc ("name", "TOP"))

(*
let mk_globs internal imports =
  let imported = imported_globs imports in
  let internal' = List.map (fun (x : Wasm.Ast.global) -> Glob x) internal in
  imported @ internal'
*)
let mk_funcs internal imports =
  let imported = imported_funcs imports in
  let internal' = List.map (fun (x : Wasm.Ast.func) -> Func x) internal in
  imported @ internal'

(*
let mk_tables internal imports =
  let imported = imported_tables imports in
  let internal' = List.map (fun (x : tableInst) -> Table x) internal in
  imported @ internal'

let mk_mems internal imports =
  let imported = imported_mems imports in
  let internal' = List.map (fun (x : memInst) -> Mem x) internal in
  imported @ internal'
*)
let instantiate_module (m : mod_) : instance =
  let m = m.it in
  let types = m.types in
  let elems = m.elems in
  let datas = m.datas in
  let exports = m.exports in
  { types; funcs = mk_funcs m.funcs m.imports; elems; datas; exports }
