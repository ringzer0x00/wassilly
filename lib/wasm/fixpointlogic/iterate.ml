let wStack = Stackwidening.wStack

module SCG = Scg.SCC
module Value = Answer

let wVal ms1 ms2 = Value.widen ms1 ms2

let rec iterate funcs call _cstack stack cache1 pres evalf =
  let stackWidened, callWidened = wStack stack call in
  let valNew, cache2, scg =
    evalf funcs callWidened _cstack stackWidened cache1 pres
  in
  if SCG.mem callWidened scg then
    let valOld =
      if Cache.Cache.mem callWidened cache2 then
        snd (Cache.Cache.find callWidened cache2)
      else Value.bot
    in
    let valWidened = wVal valOld valNew in

    let stable =
      if Value.leq valWidened valOld && SCG.cardinal scg = 1 then
        Cache.Cache.Stable
      else Cache.Cache.Unstable
    in
    let cache3 = Cache.Cache.add callWidened (stable, valWidened) cache2 in
    if Value.le valOld valWidened then
      iterate funcs call _cstack stack cache3 pres evalf
    else (valWidened, cache3, SCG.diff scg (SCG.singleton callWidened))
  else (valNew, cache2, scg)
