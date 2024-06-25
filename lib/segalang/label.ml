type cont = Command.Language.t
type block_type = Command.Language.arity
type labelcontent = { body : cont; brcont : cont; typ : block_type }
type t = BlockLabel of labelcontent | LoopLabel of labelcontent

let block l = BlockLabel l
let loop l = LoopLabel l
let body = function BlockLabel lc | LoopLabel lc -> lc.body
