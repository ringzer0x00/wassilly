
(module
    (import "host" "mutate" (func $mutate (param i32)))
    (import "host" "pippo" (global $pippo i32))
    (func $main (export "main")
        i32.const 1337
        i32.load
        call_indirect (param) (result)
    )
    (func $a
        ;; i32.const 23
        ;; call $print
    )
    (func $not-reachable
        ;; i32.const 42
        ;; call $print
    )

    (table $table 2 funcref)
    (elem $table (i32.const 0) $not-reachable $a)
)