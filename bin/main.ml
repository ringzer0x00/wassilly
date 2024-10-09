let usage_msg = "append <file1> ... -o <output>"
let verbose = ref false
let input_files = ref ""
let specfile = ref ""
let output_file = ref ""
let anon_fun filename = input_files := filename

let speclist =
  [
    ("-verbose", Arg.Set verbose, "Output debug information");
    ("-s", Arg.Set_string specfile, "Specfile");
    ("-o", Arg.Set_string output_file, "Set output file name");
  ]

let () =
  Arg.parse speclist anon_fun usage_msg;
  if !input_files = "" then print_endline usage_msg
  else
    Interpreter.Analysis.callgraph_analysis' !input_files !specfile
    |> Datastructures.Callgraph.CallGraph.print
