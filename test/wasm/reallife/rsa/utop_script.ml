let d = "/home/ringzero/gitrepos/wassilly/test/wasm/reallife/rsa"

let () = Utilities.Conf.debug := true

let p =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ "/rsa_lib_bg.wasm")
    (d ^ "/wassilly.spec");;


let d = "/home/ringzero/gitrepos/wassilly/test/wasm/reallife/rsa"

let () = Utilities.Conf.debug := true

let p =
  Interpreter.Analysis.callgraph_analysis'
    (d ^ "/test.wasm")
    ("");;