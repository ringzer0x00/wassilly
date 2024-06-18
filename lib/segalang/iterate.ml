let wStack = Stackwidening.wStack

module SCG = Scg

let wVal ms1 ms2 = Result.widen ms1 ms2

let rec iterate funcs call stack cache1 pres evalf =
  let stackWidened, callWidened = wStack stack call in
  let valNew, cache2, scg = evalf funcs callWidened stackWidened cache1 pres in
  if SCG.mem callWidened scg then
    let valOld =
      if Cache.mem callWidened cache2 then snd (Cache.find callWidened cache2)
      else Result.bot
    in
    let valWidened = wVal valOld valNew in

    let stable =
      if Result.leq valWidened valOld && SCG.cardinal scg = 1 then Cache.Stable
      else Cache.Unstable
    in
    let cache3 = Cache.add callWidened (stable, valWidened) cache2 in
    if Result.le valOld valWidened then
      iterate funcs call stack cache3 pres evalf
    else (valWidened, cache3, SCG.diff scg (SCG.singleton callWidened))
  else (valNew, cache2, scg)
