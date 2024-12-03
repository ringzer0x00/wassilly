(module
  ;; import the browser console object, you'll need to pass this in from JavaScript
  (func
    ;; create a local variable and initialize it to 0
    (local $i i32)

    (loop $my_loop

      ;; add one to $i
      local.get $i
      i32.const 1
      i32.add
      local.set $i

      ;; if $i is less than 10 branch to loop
      local.get $i
      i32.const 10
      i32.lt_s
      br $my_loop

    )
  )

  (export "loop" (func 0))
)
