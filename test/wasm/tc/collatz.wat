(module
  (func $steps (export "steps") (param $number i32) (result i32)
    (if (i32.le_s (local.get $number) (i32.const 1))
      (then (return (select
        (i32.const 0) ;; base case
        (i32.const -1) ;; error condition
        (i32.eq (local.get $number) (i32.const 1))
      )))
    )
    (return (i32.add (i32.const 1) (call $steps (select
      (i32.add (i32.mul (i32.const 3) (local.get $number)) (i32.const 1)) ;; odd
      (i32.div_u (local.get $number) (i32.const 2)) ;; even 
      (i32.rem_u (local.get $number) (i32.const 2))
    ))))
  )
)