module Tabs = Memories.Tables
module Tab = Memories.Table
module VM = Memories.Variablemem.VariableMem
module VMKey = Memories.Variablemem.MapKey
open Datastructures.Monad.DefBot

let listnth_i32 l i = List.nth l (Int32.to_int i)

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

let cc (c : Wasm.Ast.const) = c.it

let init_globals (mod_ : Wasm.Ast.module_) (s : Memories.Memorystate.t) =
  let eval p ms =
    Eval.step mod_ (ms, p) Eval.Stack.empty Eval.Cache.empty Int32.minus_one
      ([], []) Eval.MA.bot_pa
  in
  let prepped = List.mapi (fun x y -> (Int32.of_int x, y)) mod_.it.globals in
  let rec aux (gs_idx : (int32 * Wasm.Ast.global) list) s =
    match gs_idx with
    | [] -> s
    | (i, gl) :: t ->
        let ty_val = match gl.it.gtype with GlobalType (t, _) -> t in
        let nty =
          match ty_val with
          | NumType n -> n
          | _ -> failwith "cannot handle these now @init"
        in
        let binding : VMKey.t = { i; t = nty } in
        let s' = Memories.Memorystate.bind_vars binding Glob s in
        let r, _, _ = eval gl.it.ginit.it s' in
        (*do other stuff*)
        let r_nat =
          match r with Def d -> d.return | Bot -> failwith "diobo"
        in
        let exp = Memories.Memorystate.peek_operand r_nat |> List.hd in
        let nat = Memories.Memorystate.assign_var s' Glob binding exp in
        aux t nat
  in
  aux prepped s

let init_mem (mod_ : Wasm.Ast.module_) (s : Memories.Memorystate.t) =
  let _eval p ms =
    Eval.step mod_ (ms, p) Eval.Stack.empty Eval.Cache.empty Int32.minus_one
      ([], []) Eval.MA.bot_pa
  in
  let prepped = mod_.it.datas in
  let rec aux (gs_idx : Wasm.Ast.data_segment list) s =
    match gs_idx with
    | [] -> s
    | gl :: t ->
        let interpret_data_segment (ds : Wasm.Ast.data_segment) _m =
          let segment_mode, _init = (ds.it.dmode, ds.it.dinit) in
          match segment_mode.it with
          | Wasm.Ast.Declarative -> assert false
          | Wasm.Ast.Passive -> _m
          | Wasm.Ast.Active { index = _; offset = _offset } ->
              (*each "piece" is 1byte (1 char) (1 word) -> can become sequence -> can become list *)
              let b = String.to_bytes _init in
              let _bseq = Bytes.to_seq b in
              let _ =
                Seq.iter
                  (fun x -> Printf.printf "CHAR: %i\n" (Char.code x))
                  _bseq (*goes to int from char*)
              in
              Printf.printf "init: %a ; " output_bytes b;
              Printf.printf "size: %i\n" (Bytes.length b);
              Printf.printf "val: %i\n"
                (Int32.to_int (Bytes.get_int32_le (String.to_bytes _init) 0));
              let _ =
                Seq.mapi
                (*byte, idx -> write (convert byte to abstract bits) @ idx+offset*)
              in
              failwith "no se puedeee"
        in
        let s' = interpret_data_segment gl s in
        aux t s'
  in
  aux prepped s

let interpret_elem_segment (es : Wasm.Ast.elem_segment) (t : 'a list) =
  let m, _val_to_copy, _type = (es.it.emode, es.it.einit, es.it.etype) in
  let _ =
    match _type with
    | ExternRefType -> failwith "stub"
    | FuncRefType -> failwith "funcreftype"
  in
  let _ = match es.it.einit with [] -> failwith "miaOOOO" | h :: _ -> h.it in
  (*init is a list because element segment represents a vector of shit copied in table from an offset*)
  match m.it with
  | Wasm.Ast.Declarative -> assert false
  | Wasm.Ast.Passive -> t
  | Wasm.Ast.Active { index = i; offset = _offset } ->
      let update _ (_einit : Wasm.Ast.const list) x = x in
      let t' =
        List.mapi
          (fun ix x ->
            if ix = Int32.to_int i.it then
              update (i.it, _offset.it) _val_to_copy x
            else x)
          t
      in
      t'

(*ELEMENT SEGMENTS - elemss

  The initial contents of a table is uninitialized. Element segments can be used to initialize a subrange of a table from a static vector of elements.

  The elems component of a module defines a vector of element segments. Each element segment defines a reference type and a corresponding list of constant element
  expressions.

  Element segments have a mode that identifies them as either passive, active, or declarative. A passive element segment’s elements can be copied to a table
  using the table.init instruction. An active element segment copies its elements into a table during instantiation, as specified by a table index and a
  constant expression defining an offset into that table. A declarative element segment is not available at runtime but merely serves to forward-declare
  references that are formed in code with instructions like ref.func.*)
let init_tab (mod_ : Wasm.Ast.module_) _ms =
  let eval p ms =
    Eval.step mod_ (ms, p) Eval.Stack.empty Eval.Cache.empty Int32.minus_one
      ([], []) Eval.MA.bot_pa
  in
  let _extracted =
    List.map
      (fun (e : Wasm.Ast.elem_segment) ->
        (e.it.emode.it, e.it.einit, e.it.etype))
      mod_.it.elems
  in
  let interpret_segment s map =
    let mode, (_einit : Wasm.Ast.const list), _etype = s in
    match mode with
    | Wasm.Ast.Declarative -> assert false
    | Wasm.Ast.Passive -> map
    | Wasm.Ast.Active { index = _; offset = _offset } ->
        let _pos = _offset.it in
        let off, _, _ = eval _offset.it _ms in
        let off =
          match off with
          | Def d -> d.return
          | Bot -> failwith "failure @ table init"
        in
        let _offset_value = Memories.Memorystate.peek_operand off |> List.hd in
        let _extr_offset_int =
          match _offset_value with
          | Expression (ex, _) ->
              Apronext.Abstractext.bound_texpr Apronext.Apol.man
                (match _ms with
                | Def d -> d.var.ad
                | Bot -> failwith "bot @ init table")
                ex
              |> Apronext.Intervalext.to_float |> fst |> Float.to_int
          | _ -> failwith "errore in init"
        in
        let init_mapped =
          List.mapi (fun i e -> (Int32.of_int (i + _extr_offset_int), e)) _einit
        in
        let map' =
          List.fold_left
            (fun map ((_idx, x) : int32 * Wasm.Ast.const) ->
              let _r, _, _ = eval x.it _ms in
              let _res =
                Memories.Memorystate.peek_operand
                  (match _r with Def d -> d.return | Bot -> failwith "init")
                |> List.hd
              in
              match _res with
              | FuncRef (_rt, _opt_fbody, _tidx)
              (*Wasm.Types.ref_type * int32 option * int32*) ->
                  Memories.Table.add _idx (_opt_fbody, _tidx) map
              | _ -> failwith "nope @ init")
            map init_mapped
        in
        map'
  in
  let r =
    List.fold_left
      (fun acc x -> interpret_segment x acc)
      Memories.Table.empty _extracted
  in
  Printf.printf "MAP LENGTH @ TABLES: %i\n"
    (Memories.Table.T.bindings r |> List.length);
  r

let init (_mod : Wasm.Ast.module_) : Memories.Memorystate.t =
  (*always alloc a memory page*)
  let ms_start : Eval.MS.ms t =
    Def
      {
        ops = [];
        mem = Memories.Linearmem.alloc_page_top;
        (*https://webassembly.github.io/spec/core/text/values.html#strings
          hex speratated by \. use int_of_string with appropriate shit*)
        var =
          VM.empty
            (Apronext.Apol.top (Datastructures.Aprondomain.make_env [||] [||]));
        tab = [];
      }
  in
  let _ =
    match _mod.it.imports with
    | [] -> ()
    | _ -> failwith "imports are present, program rejected"
  in
  let _tab_initialized = [ init_tab _mod ms_start ] in
  let globs_initialized =
    init_globals _mod
      (Def
         {
           ops = [];
           mem = Memories.Linearmem.alloc_page_top;
           var =
             VM.empty
               (Apronext.Apol.top
                  (Datastructures.Aprondomain.make_env [||] [||]));
           tab = _tab_initialized;
         })
  in
  init_mem _mod globs_initialized
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

(*(
  match _init with
  | "" | _ ->
      (* index is ignored as there is at most one memory*)
      failwith
        "write _init (content) into _idx of _m at _offset.\n\
        \          _init is string, figure out how to convert it")*)
