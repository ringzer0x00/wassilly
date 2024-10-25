(module
  (func (;0;) (result i32)
    i32.const 5777216
    i32.const 7
    i32.store offset=82
    i32.const 5777216
    i32.load offset=82
  )
  (table (;0;) 0 funcref)
  (memory (;0;) 256)
  (export "_start" (func 0)))
