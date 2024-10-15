open Datastructures.Abstractbit

let min_siexteen = Array.append (Array.make 28 One) (Array.make 4 Zero)

let vtables_corr =
  [
    (0, "args_sizes_get");
    (1, "args_get");
    (2, "proc_exit");
    (3, "__wasm_call_ctors");
    (4, "module1_bool_");
    (5, "module2_bool_");
    (6, "main");
    (7, "A::method__");
    (8, "B::method__");
    (9, "C::method__");
    (10, "D::method__");
    (11, "_start");
    (12, "__original_main");
    (13, "__main_void");
    (14, "main.1");
    (15, "_Exit");
    (16, "libc_exit_fini");
    (17, "exit");
    (18, "_fini");
    (19, "stackSave");
    (20, "stackRestore");
    (21, "stackAlloc");
    (22, "__errno_location");
  ]
  |> List.map (fun (x, y) -> (Int32.of_int x, y))
