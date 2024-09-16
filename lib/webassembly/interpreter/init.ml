module Tabs = Memories.Tables
module Tab = Memories.Table
module VM = Memories.Variablemem.VariableMem
module VMKey = Memories.Variablemem.MapKey
open Datastructures.Monad.DefBot

type modinst = Memories.Instance.instance

let listnth_i32 l i = List.nth l (Int32.to_int i)
let cc (c : Wasm.Ast.const) = c.it

let eval p ms mod_ =
  Eval.step mod_ (ms, p) Eval.Stack.empty Eval.Cache.empty Int32.minus_one
    ([], []) Eval.MA.bot_pa

let ifun_indexed x =
  List.filter
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with Wasm.Ast.FuncImport _ -> true | _ -> false)
    x
  |> List.mapi (fun i x -> (i, x))

let init_mem (mod_ : modinst) (s : Memories.Memorystate.t) datas _memories =
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
              let _offstate, _, _ = eval (cc _offset) _m mod_ in
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
  aux datas s

let init_tab (mod_ : modinst) pre elems _tabs : Eval.MS.t =
  let extract_segment elem =
    (fun (e : Wasm.Ast.elem_segment) -> (e.it.emode.it, e.it.einit, e.it.etype))
      elem
  in
  let interpret_segment s map =
    let mode, (_einit : Wasm.Ast.const list), _etype = s in
    match mode with
    | Wasm.Ast.Declarative -> assert false
    | Wasm.Ast.Passive -> map
    | Wasm.Ast.Active { index = _; offset } ->
        let off, _, _ = eval offset.it pre mod_ in
        off >>=? fun d ->
        let _offset_value =
          Memories.Memorystate.peek_operand d.return |> List.hd
        in
        let _extr_offset_int =
          match _offset_value with
          | Expression (ex, _) ->
              Apronext.Abstractext.bound_texpr Apronext.Apol.man
                (pre >>=? fun m -> m.var.ad)
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
              let _r, _, _ = eval x.it pre mod_ in
              let _res =
                Memories.Memorystate.peek_operand (_r >>=? fun d -> d.return)
                |> List.hd
              in
              match _res with
              | FuncRef (_rt, _opt_fbody, _tidx) ->
                  Memories.Table.add _idx (_opt_fbody, _tidx) map
              | _ -> failwith "nope @ init")
            map init_mapped
        in
        map'
  in
  let r =
    List.fold_left
      (fun acc (x : Wasm.Ast.elem_segment) ->
        interpret_segment (extract_segment x) acc)
      Memories.Table.empty elems
  in
  Printf.printf "MAP LENGTH @ TABLES: %i\n"
    (Memories.Table.T.bindings r |> List.length);
  pre >>=? fun m : Memories.Memorystate.t ->
  Def { ops = m.ops; mem = m.mem; var = m.var; tab = [ r ] }

let init_globals (mod_ : modinst) (s : Memories.Memorystate.t) prepped =
  let rec aux (gs_idx : (int32 * Memories.Instance.glob) list) s =
    match gs_idx with
    | [] -> s
    | (i, gl) :: t -> (
        match gl with
        | Glob gl ->
            let ty_val = match gl.it.gtype with GlobalType (t, _) -> t in
            let nty =
              match ty_val with
              | NumType n -> n
              | _ -> failwith "cannot handle these now @init"
            in
            let binding : VMKey.t = { i; t = nty } in
            let s' = Memories.Memorystate.bind_vars binding Glob s in
            let r, _, _ = eval gl.it.ginit.it s' mod_ in
            (*do other stuff*)
            let r_nat =
              match r with Def d -> d.return | Bot -> failwith "diobo"
            in
            let exp = Memories.Memorystate.peek_operand r_nat |> List.hd in
            let nat = Memories.Memorystate.assign_var s' Glob binding exp in
            aux t nat
        | _ -> failwith "imported global")
  in
  aux prepped s

let iglob_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.GlobalImport t -> Some (Memories.Instance.ImportedGlob t)
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let itab_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.TableImport t -> Some (Memories.Instance.ImportedTable t)
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let imem_indexed x =
  List.filter_map
    (fun (x : Wasm.Ast.import) ->
      match x.it.idesc.it with
      | Wasm.Ast.MemoryImport t -> Some (Memories.Instance.ImportedMemory t)
      | _ -> None)
    x
  |> List.mapi (fun i x -> (Int32.of_int i, x))

let index_globs globs imps =
  List.mapi
    (fun i (x : Wasm.Ast.global) ->
      (Int32.of_int (i + imps), Memories.Instance.Glob x))
    globs

let index_tabs tabs imps =
  List.mapi
    (fun i (x : Wasm.Ast.table) ->
      (Int32.of_int (i + imps), Memories.Instance.Table x))
    tabs

let index_mems mems imps =
  List.mapi
    (fun i (x : Wasm.Ast.memory) ->
      (Int32.of_int (i + imps), Memories.Instance.Memory x))
    mems

let init (_mod : Wasm.Ast.module_) =
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
  let internal_globs =
    index_globs _mod.it.globals (List.length _imported_globs)
  in
  let internal_mems =
    index_mems _mod.it.memories (List.length _imported_mems)
  in
  let internal_tabs = index_tabs _mod.it.tables (List.length _imported_tabs) in
  let globs = _imported_globs @ internal_globs in
  let tabs = _imported_tabs @ internal_tabs in
  let mems = _imported_mems @ internal_mems in
  let _mod_inst = Memories.Instance.instantiate_module _mod in
  let globs_initialized : Eval.MS.ms t =
    init_globals _mod_inst ms_start globs
  in
  let tab_initialized =
    init_tab _mod_inst globs_initialized _mod_inst.elems tabs
  in
  let mem_initialized =
    init_mem _mod_inst tab_initialized _mod_inst.datas mems
  in
  (mem_initialized, _mod_inst)
