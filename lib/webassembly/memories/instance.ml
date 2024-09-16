(* an instance of a wasm module contains the "running" module strucutre:
   funcs -> | ImportedFuncSpec of .. | FuncBody
   globs -> | ImportedGlobSpec of .. | Glob
   mems -> | ImportedMemSpec of .. | Mem
   tables -> | ImportedTableSpec of .. | Table
*)

type name = string
type spec = int32 * name * string

(* -- *)
type definedFunc = Wasm.Ast.func
type definedGlob = Wasm.Ast.global
type memInst = Linearmem.t
type tableInst = Table.t

(* -- *)
type func = Func of definedFunc | ImportedFunc of spec

type glob =
  | Glob of Wasm.Ast.global
  | ImportedGlob of Wasm.Types.global_type * name

type table =
  | Table of Wasm.Ast.table
  | ImportedTable of Wasm.Types.table_type * name

type mem =
  | Memory of Wasm.Ast.memory
  | ImportedMemory of Wasm.Types.memory_type * name

(*--*)
type mod_ = Wasm.Ast.module_

type instance = {
  types : Wasm.Ast.type_ list;
  funcs : func list;
  elems : Wasm.Ast.elem_segment list;
  datas : Wasm.Ast.data_segment list;
  exports : Wasm.Ast.export list;
  importspecs : string;
}

let imported_funcs (i : Wasm.Ast.import list) =
  let filter_map (x : Wasm.Ast.import) =
    match x.it.idesc.it with
    | FuncImport v ->
        Some (ImportedFunc (v.it, Wasm.Utf8.encode x.it.item_name, ""))
    | _ -> None
  in
  List.filter_map filter_map i

let ifun_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.FuncImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let iglob_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.GlobalImport t ->
          Some (ImportedGlob (t, Wasm.Utf8.encode x.it.item_name))
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let itab_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.TableImport t ->
          Some (ImportedTable (t, Wasm.Utf8.encode x.it.item_name))
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let imem_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.MemoryImport t ->
          Some (ImportedMemory (t, Wasm.Utf8.encode x.it.item_name))
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let index_globs globs imps =
  List.mapi
    (fun i (x : Wasm.Ast.global) -> (Int32.of_int (i + imps), Glob x))
    globs

let index_tabs tabs imps =
  List.mapi
    (fun i (x : Wasm.Ast.table) -> (Int32.of_int (i + imps), Table x))
    tabs

let index_mems mems imps =
  List.mapi
    (fun i (x : Wasm.Ast.memory) -> (Int32.of_int (i + imps), Memory x))
    mems

let mk_funcs internal imports =
  let imported = imported_funcs imports in
  let internal' = List.map (fun (x : Wasm.Ast.func) -> Func x) internal in
  imported @ internal'

let instantiate_module (m : mod_) : instance =
  let m = m.it in
  let types = m.types in
  let elems = m.elems in
  let datas = m.datas in
  let exports = m.exports in
  let importspecs = "" in
  {
    types;
    funcs = mk_funcs m.funcs m.imports;
    elems;
    datas;
    exports;
    importspecs;
  }
