open Datastructures.Abstractbit

let min_siexteen = Array.append (Array.make 28 One) (Array.make 4 Zero)

let vtables_gt =
  [
    (4, 7);
    (4, 8);
    (4, 9);
    (4, 10);
    (5, 7);
    (5, 8);
    (5, 9);
    (5, 10);
    (6, 4);
    (6, 5);
    (11, 3);
    (11, 12);
    (11, 17);
    (12, 13);
    (13, 0);
    (13, 1);
    (13, 2);
    (13, 14);
    (14, 6);
    (15, 2);
    (16, 18);
    (17, 15);
    (17, 16);
    (17, 18);
  ]

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
    (12, "__main_void");
    (13, "dummy");
    (14, "libc_exit_fini");
    (15, "exit");
    (16, "_Exit");
    (17, "_emscripten_stack_restore");
    (18, "emscripten_stack_get_current");
  ]
  |> List.map (fun (x, y) -> (Int32.of_int x, y))
