let usage_msg = "wassilly <file.wasm> [-v | -o <graph.dot> | -s <specfile.silly>]"
let verbose = Utilities.Conf.debug
let input_files = ref ""
let specfile = ref ""
let output_file = ref ""
let anon_fun filename = input_files := filename

let speclist =
  [
    ("-v", Arg.Set verbose, "(verbose) Output debug information");
    ("-s", Arg.Set_string specfile, "(spec) path to specification file");
    ("-o", Arg.Set_string output_file, "(output) Set output file name");
  ]

let () =
  Arg.parse speclist anon_fun usage_msg;
  if !input_files = "" then print_endline usage_msg
  else
    let g = Interpreter.Analysis.callgraph_analysis' !input_files !specfile in
    match !output_file with
    | "" -> Datastructures.Callgraph.print_graph Format.std_formatter g
    | _ -> Datastructures.Callgraph.write_to_file !output_file g
