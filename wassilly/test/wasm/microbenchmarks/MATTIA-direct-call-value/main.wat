
(module
    (import "host" "unknown" (func $unknown (result i32)))
    (func $main (export "main") (result i32)
        call $unknown
    )
    (func $a (param i32)
        ;; i32.const 23
        ;; call $print
    )
    (func $not-reachable (param i32)
        ;; i32.const 42
        ;; call $print
    )

    (table $table 2 funcref)
    (elem $table (i32.const 0) $not-reachable $a)
)