let wStack = Stackwidening.wStack

module SCG = Scg.SCC
module Value = Answer
module MS = Memories.Memorystate
module OS = Memories.Operandstack
module LM = Labelmap.LabelMap
open Datastructures.Monad.DefBot

let printer = Utilities.Printer.print
let printerbypass = Utilities.Printer.print_always
let wVal ms1 ms2 = Value.widen ms1 ms2

let debug_call_summary prefix (ms, cmd) =
  let cmd_len = List.length cmd in
  let ms_info =
    match ms with
    | Bot -> "Bot"
    | Def ms' ->
        let stack = MS.ops ms' in
        let stack_len = List.length stack in
        let label_len = List.length (OS.lsk stack) in
        Printf.sprintf "Def(stack=%d,labels=%d)" stack_len label_len
  in
  printerbypass Format.print_string
    (Printf.sprintf "%s call=%s cmd_len=%d\n" prefix ms_info cmd_len)

let debug_print_scg label scg =
  let size = SCG.cardinal scg in
  printerbypass Format.print_string
    (Printf.sprintf "%s SCC(size=%d)\n" label size);
  if size > 0 then
    SCG.iter (fun call -> debug_call_summary "  node" call) scg

let debug_answer_summary label answer =
  let summary =
    match answer with
    | Bot -> "Bot"
    | Def res ->
        let nat_state =
          match Value.nat res with Bot -> "Bot" | Def _ -> "Def"
        in
        let ret_state =
          match Value.ret res with Bot -> "Bot" | Def _ -> "Def"
        in
        let br_empty = LM.eq (Value.br res) LM.empty in
        Printf.sprintf "Def(nat=%s,return=%s,br_empty=%b)" nat_state ret_state
          br_empty
  in
  printerbypass Format.print_string
    (Printf.sprintf "%s %s\n" label summary)
(*
let rec _iterate_old funcs call stack cache1 fin ft pres evalf =
  printer Format.print_string "{iterate}";
  let stackWidened, callWidened, _stackMod = wStack stack call in
  let valNew, cache2, scg =
    evalf funcs callWidened stackWidened cache1 fin ft pres
  in
  printer Format.print_string "########################### evalf done\n";
  if SCG.mem callWidened scg then
    let valOld =
      if Cache.Cache.mem callWidened cache2 then
        snd (Cache.Cache.find callWidened cache2)
      else Bot
    in
    let valWidened = wVal valOld valNew in

    let stable =
      if Value.leq valWidened valOld && SCG.cardinal scg = 1 then
        Cache.Cache.Stable
      else Cache.Cache.Unstable
    in
    let cache3 = Cache.Cache.add callWidened (stable, valWidened) cache2 in
    if Value.le valOld valWidened then (
      printer Format.print_string "valOld < valWidened, iterate\n";
      iterate funcs call stack cache3 fin ft pres evalf)
    else (
      printer Format.print_string "REMOVED CALL WIDENED FROM SCG\n";
      (valWidened, cache3, SCG.diff scg (SCG.singleton callWidened)))
  else (
    printer Format.print_string
      "########################### call does not belong in SCG;\n";
    (valNew, cache2, scg))
*)
let rec iterate funcs call stack cache1 fin ft pres evalf =
  printer Format.print_string "{iterate}";
  debug_call_summary "Iterate entry" call;
  let valNew, cache2, scg =
    evalf funcs call stack cache1 fin ft pres
  in
  debug_print_scg "Iterate post-eval" scg;
  debug_answer_summary "Iterate valNew" valNew;
  (*printerbypass Format.print_string "########################### evalf done\n";*)
  if SCG.mem call scg then
    (let raw_member = SCG.mem call scg in
     printerbypass Format.print_string
       (Printf.sprintf
          "eval-after-iterate-inSCC (raw_mem=%b, leq_mem=true)\n" raw_member);
    let valOld =
      if Cache.Cache.mem call cache2 then
        (printerbypass Format.print_string "Cache hit @ iterate\n";
        snd (Cache.Cache.find call cache2))
      else (
        printerbypass Format.print_string "Cache miss @ iterate\n";
        Bot)
    in
    debug_answer_summary "Iterate cached valOld" valOld;
    let valWidened = wVal valOld valNew in
    debug_answer_summary "Iterate widened" valWidened;

    let stable =
      if Value.leq valWidened valOld && SCG.cardinal scg = 1 then (
        printerbypass Format.print_string "Marking call Stable\n";
        Cache.Cache.Stable)
      else (
        printerbypass Format.print_string "Marking call Unstable\n";
        Cache.Cache.Unstable)
    in
    let cache3 = Cache.Cache.add call (stable, valWidened) cache2 in
    if Value.le valOld valWidened then (
      printer Format.print_string "valOld < valWidened, iterate\n";
      iterate funcs call stack cache3 fin ft pres evalf)
    else (
      printerbypass Format.print_string "REMOVED CALL FROM SCG\n";
      printer Format.print_string "REMOVED CALL WIDENED FROM SCG\n";
      (valWidened, cache3, SCG.diff scg (SCG.singleton call))))
  else (
    let raw_member = SCG.mem call scg in
    printerbypass Format.print_string
      (Printf.sprintf
         "Iterate: call not considered in SCC (raw_mem=%b, leq_mem=false)\n"
         raw_member);
    printerbypass Format.print_string
      "########################### call does not belong in SCG;\n";
    (valNew, cache2, scg))
