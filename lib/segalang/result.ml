type mem = Memory.t
type lmap = Labelmap.t
type t = { nat : mem; br : lmap; return : mem }
type partial_result = { br : lmap; return : mem }
