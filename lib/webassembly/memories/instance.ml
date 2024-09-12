(* an instance of a wasm module contains the "running" module strucutre:
   funcs -> | ImportedFuncSpec of .. | FuncBody
   globs -> | ImportedGlobSpec of .. | Glob
   mems -> | ImportedMemSpec of .. | Mem
   tables -> | ImportedTableSpec of .. | Table
*)
type spec = string

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

let x = ImportedTable "2"

(*--*)
type mod_ = Wasm.Ast.module_

let instantiate_module (m : mod_) = m

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
