(module
 (table 0 funcref)
 (memory $0 1)
 (export "memory" (memory $0))
 (export "fib" (func $fib))
 (func $fib (; 0 ;) (param $0 i32) (result i32)
  (block $label$0
   (br_if $label$0
    (i32.ge_s
     (local.get $0)
     (i32.const 2)
    )
   )
   (return
    (local.get $0)
   )
  )
  (i32.add
   (call $fib
    (i32.add
     (local.get $0)
     (i32.const -1)
    )
   )
   (call $fib
    (i32.add
     (local.get $0)
     (i32.const -2)
    )
   )
  )
 )
)