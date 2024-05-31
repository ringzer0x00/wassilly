(*type module_ = module_' Source.phrase
  and module_' =
  {
    types : type_ list;
    globals : global list;
    tables : table list;
    memories : memory list;
    funcs : func list;
    start : start option;
    elems : elem_segment list;
    datas : data_segment list;
    imports : import list;
    exports : export list;
  }*)

(*ELEMENT SEGMENTS - elemss

  The initial contents of a table is uninitialized. Element segments can be used to initialize a subrange of a table from a static vector of elements.

  The elems component of a module defines a vector of element segments. Each element segment defines a reference type and a corresponding list of constant element
  expressions.

  Element segments have a mode that identifies them as either passive, active, or declarative. A passive element segment’s elements can be copied to a table
  using the table.init instruction. An active element segment copies its elements into a table during instantiation, as specified by a table index and a
  constant expression defining an offset into that table. A declarative element segment is not available at runtime but merely serves to forward-declare
  references that are formed in code with instructions like ref.func.*)

(* Data Segments

   The initial contents of a memory are zero bytes. Data segments can be used to initialize a range of memory from a static vector of bytes.
   The datas component of a module defines a vector of data segments.

   Like element segments, data segments have a mode that identifies them as either passive or active.

   A passive data segment’s contents can be copied into a memory using the memory.init instruction.
   An active data segment copies its contents into a memory during instantiation, as specified by a memory index and a constant expression defining
   an offset into that memory.

   Data segments are referenced through data indices.

   Note:
   In the current version of WebAssembly, at most one memory is allowed in a module. Consequently, the only valid memidx is 0.*)

(*do things with memories, tables, globals, produce material to build a Frame*)

let interpret_data_segment (ds : Wasm.Ast.data_segment) _m =
  let segment_mode, _init = (ds.it.dmode, ds.it.dinit) in
  match segment_mode.it with
  | Wasm.Ast.Declarative -> assert false
  | Wasm.Ast.Passive -> _m
  | Wasm.Ast.Active { index = _; offset = _offset } -> (
      match _init with
      | "" | _ ->
          (* index is ignored as there is at most one memory*)
          failwith "write _init (content) into _idx of _m at _offset.
          _init is string, figure out how to convert it")

let init (_mod : Wasm.Ast.module_) =
  (*always alloc a memory page*)
  let _mem_initialized = Memories.Linearmem.alloc_page_top in
  let _mem' =
    List.fold_left
      (fun m d -> interpret_data_segment d m)
      _mem_initialized _mod.it.datas
  in
  failwith ""
