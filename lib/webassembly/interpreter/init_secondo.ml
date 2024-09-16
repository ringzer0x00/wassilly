module Tabs = Memories.Tables
module Tab = Memories.Table
module VM = Memories.Variablemem.VariableMem
module VMKey = Memories.Variablemem.MapKey
open Datastructures.Monad.DefBot

let listnth_i32 l i = List.nth l (Int32.to_int i)
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
  let eval p ms =
    Eval.step mod_ (ms, p) Eval.Stack.empty Eval.Cache.empty Int32.minus_one
      ([], []) Eval.MA.bot_pa
  in
  let prepped = mod_.it.datas in
  let rec aux (gs_idx : Wasm.Ast.data_segment list) s =
    match gs_idx with
    | [] -> s
    | gl :: t ->
        let interpret_data_segment (ds : Wasm.Ast.data_segment)
            (_m : Memories.Memorystate.t) =
          let segment_mode, _init = (ds.it.dmode, ds.it.dinit) in
          match segment_mode.it with
          | Wasm.Ast.Declarative -> assert false
          | Wasm.Ast.Passive -> _m
          | Wasm.Ast.Active { index = _; offset = _offset } ->
              let _offstate, _, _ = eval (cc _offset) _m in
              let _offset, ret =
                match _offstate with
                | Def d ->
                    ( Memories.Memorystate.peek_operand d.return |> List.hd,
                      d.return )
                | Bot -> failwith "diobo @ initmem"
              in
              let _vm = match ret with Bot -> failwith "" | Def d -> d.var in
              let offset =
                Apronext.Intervalext.to_float
                  (Memories.Operand.concretize _vm _offset)
                |> fst |> Float.to_int
              in
              (*each "piece" is 1byte (1 char) (1 word) -> can become sequence -> can become list *)
              let b = String.to_bytes _init in
              let _bseq = Bytes.to_seq b in
              let _ =
                Seq.iter
                  (fun x -> Printf.printf "CHAR: %i\n" (Char.code x))
                  _bseq (*goes to int from char*)
              in
              let mapped_bits =
                Seq.map (fun x -> Char.code x) _bseq
                |> Array.of_seq
                |> Array.mapi (fun i x ->
                       ( i + offset,
                         Language.Bitwisenumber.byte_of_interval
                           (Apronext.Intervalext.of_int x x) ))
              in
              Printf.printf "MIAO: %i\n" (Array.length mapped_bits);
              Printf.printf "init: %a ; " output_bytes b;
              Printf.printf "size: %i\n" (Bytes.length b);
              Printf.printf "val: %i\n"
                (Int32.to_int (Bytes.get_int32_le (String.to_bytes _init) 0));
              let m' =
                Array.fold_left
                  (fun m (_to, (_val : Language.Bitwisenumber.byte)) ->
                    let b =
                      Datastructures.Abstractbyte.join _val.min _val.max
                    in
                    let _ =
                      Printf.printf "to write: ";
                      Datastructures.Abstractbyte.print_byte b;
                      Printf.printf "\n"
                    in
                    Memories.Memorystate.write_mem_raw m _to b)
                  _m mapped_bits
              in
              let _ =
                match m' with
                | Def d -> Memories.Linearmem.printmem d.mem
                | Bot -> failwith "memoryyyy"
              in
              m'
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

let iglob_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.GlobalImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let ifun_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.FuncImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let imem_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.MemoryImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let itab_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.TableImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let init (_mod : Wasm.Ast.module_) : Memories.Memorystate.t =
  let ms_start : Eval.MS.ms t =
    Def
      {
        ops = [];
        mem = Memories.Linearmem.alloc_page;
        var =
          VM.empty
            (Apronext.Apol.top (Datastructures.Aprondomain.make_env [||] [||]));
        tab = [];
      }
  in
  (*always alloc a memory page*)
  let _imported_globs, _imported_funs, _imported_tabs, _imported_mems =
    ( iglob_indexed _mod.it.imports,
      ifun_indexed _mod.it.imports,
      itab_indexed _mod.it.imports,
      imem_indexed _mod.it.imports )
  in

  (*allocate and initialize imports!*)
  let _tab_initialized = [ init_tab _mod ms_start ] in
  let globs_initialized =
    init_globals _mod
      (Def
         {
           ops = [];
           mem = Memories.Linearmem.alloc_page;
           var =
             VM.empty
               (Apronext.Apol.top
                  (Datastructures.Aprondomain.make_env [||] [||]));
           tab = _tab_initialized;
         })
  in
  init_mem _mod globs_initialized
