module Term = Importspec.Term

type name = string
type spec = Term.term

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
  importspecs : Term.program;
  static_mod : mod_;
}

let imported_funcs (i : Wasm.Ast.import list) (importspecs : spec list) =
  let filter_map_imports (x : Wasm.Ast.import) =
    match x.it.idesc.it with
    | FuncImport _v ->
        let n = Wasm.Utf8.encode x.it.item_name in
        Some
          (ImportedFunc
             (List.find
                (fun t ->
                  match t with
                  | Term.Func (name, _funcsig, _impl) -> n = name
                  | _ -> failwith "function not found")
                importspecs))
    | _ -> None
  in
  let filter_map_injected (p : spec) =
    match p with ImportObj f -> Some (ImportedFunc f) | _ -> None
  in

  let injected = List.filter_map filter_map_injected importspecs in
  (*parse here from importspec ImportObj*)
  List.filter_map filter_map_imports i @ injected

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

let mk_funcs internal imports (Term.Program _spec) =
  let spec_funcs =
    List.filter_map
      (fun s -> match s with Term.Func _ -> Some s | _ -> None)
      _spec
  in
  let imported = imported_funcs imports spec_funcs in
  let internal' = List.map (fun (x : Wasm.Ast.func) -> Func x) internal in
  imported @ internal'

let instantiate_module (m : mod_) spec : instance =
  let mit = m.it in
  let types = mit.types in
  let elems = mit.elems in
  let datas = mit.datas in
  let exports = mit.exports in
  let importspecs = spec in
  {
    types;
    funcs = mk_funcs mit.funcs mit.imports spec;
    elems;
    datas;
    exports;
    importspecs;
    static_mod = m;
  }
