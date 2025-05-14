let wStack = Stackwidening.wStack

module SCG = Scg.SCC
module Value = Answer
open Datastructures.Monad.DefBot

let printer = Utilities.Printer.print
let wVal ms1 ms2 = Value.widen ms1 ms2

let rec iterate funcs call stack cache1 fin ft pres evalf =
  printer Format.print_string "{iterate}";
  let stackWidened, callWidened = wStack stack call in
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
