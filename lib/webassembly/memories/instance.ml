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
type glob = Glob of definedGlob | ImportedGlob of spec
type mem = Mem of memInst | ImportedMem of spec
type table = Table of tableInst | ImportedTable of spec
type impordesc = Wasm.Ast.import_desc'

(*--*)
type mod_ = Wasm.Ast.module_

type instance = {
  types : Wasm.Ast.type_ list;
  globals : glob list;
  tables : table list;
  memories : mem list;
  funcs : func list;
  elems : Wasm.Ast.elem_segment list;
  datas : Wasm.Ast.data_segment list;
      (*exports : export list; ~ maybe functions should be tagged?*)
}

let imported_globs (i : Wasm.Ast.import list) =
  let filter (x : Wasm.Ast.import) =
    match x.it.idesc.it with GlobalImport _ -> true | _ -> false
  in
  List.filter filter i
  |> List.map (fun (_x : Wasm.Ast.import) -> ImportedGlob ("name", "TOP"))

let mkglobs gs_internal imports =
  let gs_imported = imported_globs imports in
  let gs_internal' =
    List.map (fun (x : Wasm.Ast.global) -> Glob x) gs_internal
  in
  gs_imported @ gs_internal'

let instantiate_module (m : mod_) : instance =
  let m = m.it in
  let types = m.types in
  let elems = m.elems in
  let datas = m.datas in
  {
    types;
    globals = mkglobs m.globals m.imports;
    tables = [];
    memories = [];
    funcs = [];
    elems;
    datas;
  }
