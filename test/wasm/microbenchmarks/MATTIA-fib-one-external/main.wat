;; Only direct calls. Simplest case.
;; Entry point: $main
;; Fully precise call graph (1 edge):
;;   $main -> $reachable
;; Reachable functions:
;;   $main (by construction, if it's the entry point)
;;   $reachable
(module
    (import "host" "fib" (func $fib (param i32) (result i32)))
    (func $main (export "main") (result i32)
        i32.const 42
        call $fib
    )
)