
(module
    (import "host" "mutate" (func $mutate (param i32)))
    (global $pippo i32 (i32.const 0))    
    (export "pippo" (global $pippo))
    (func $main (export "main") (result i32)
        i32.const 7
        call $mutate
        global.get $pippo
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