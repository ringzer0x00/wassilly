(module $main.wasm
  (type $t0 (func (param i32) (result i32)))
  (type $t1 (func (param i32)))
  (type $t2 (func))
  (type $t3 (func (param i32 i32) (result i32)))
  (type $t4 (func (result i32)))
  (import "wasi_snapshot_preview1" "args_sizes_get" (func $__wasi_args_sizes_get (type $t3)))
  (import "wasi_snapshot_preview1" "args_get" (func $__wasi_args_get (type $t3)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $__wasi_proc_exit (type $t1)))
  (func $__wasm_call_ctors (type $t2)
    nop)
  (func $module1_bool_ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee $l1
    global.set $__stack_pointer
    local.get $l1
    i32.const 1032
    i32.store offset=12
    local.get $l1
    i32.const 1044
    i32.store offset=8
    local.get $l1
    i32.const 12
    i32.add
    local.get $l1
    i32.const 8
    i32.add
    local.get $p0
    select
    local.tee $p0
    local.get $p0
    i32.load
    i32.load
    call_indirect $__indirect_function_table (type $t0)
    local.set $p0
    local.get $l1
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get $p0)
  (func $module2_bool_ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee $l1
    global.set $__stack_pointer
    local.get $l1
    i32.const 1056
    i32.store offset=12
    local.get $l1
    i32.const 1068
    i32.store offset=8
    local.get $l1
    i32.const 12
    i32.add
    local.get $l1
    i32.const 8
    i32.add
    local.get $p0
    select
    local.tee $p0
    local.get $p0
    i32.load
    i32.load
    call_indirect $__indirect_function_table (type $t0)
    local.set $p0
    local.get $l1
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get $p0)
  (func $main (type $t3) (param $p0 i32) (param $p1 i32) (result i32)
    local.get $p0
    i32.const 1
    i32.gt_s
    local.tee $p0
    call $module1_bool_
    local.get $p0
    call $module2_bool_
    i32.add)
  (func $A::method__ (type $t0) (param $p0 i32) (result i32)
    i32.const 23)
  (func $B::method__ (type $t0) (param $p0 i32) (result i32)
    i32.const 42)
  (func $C::method__ (type $t0) (param $p0 i32) (result i32)
    i32.const 1)
  (func $D::method__ (type $t0) (param $p0 i32) (result i32)
    i32.const 2)
  (func $_start (type $t2)
    call $__wasm_call_ctors
    call $__main_void
    call $exit
    unreachable)
  (func $__main_void (type $t4) (result i32)
    (local $l0 i32) (local $l1 i32) (local $l2 i32) (local $l3 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee $l0
    global.set $__stack_pointer
    block $B0
      local.get $l0
      local.tee $l2
      i32.const 12
      i32.add
      local.get $l0
      i32.const 8
      i32.add
      call $__wasi_args_sizes_get
      i32.eqz
      if $I1
        block $B2 (result i32)
          local.get $l0
          i32.load offset=12
          local.tee $l1
          i32.eqz
          if $I3
            i32.const 0
            local.set $l0
            i32.const 0
            br $B2
          end
          local.get $l0
          local.get $l1
          i32.const 2
          i32.shl
          local.tee $l1
          i32.const 19
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee $l0
          local.tee $l3
          global.set $__stack_pointer
          local.get $l3
          local.get $l2
          i32.load offset=8
          i32.const 15
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee $l3
          global.set $__stack_pointer
          local.get $l0
          local.get $l1
          i32.add
          i32.const 0
          i32.store
          local.get $l0
          local.get $l3
          call $__wasi_args_get
          br_if $B0
          local.get $l2
          i32.load offset=12
        end
        local.tee $l1
        local.get $l0
        call $main
        local.set $l0
        local.get $l2
        i32.const 16
        i32.add
        global.set $__stack_pointer
        local.get $l0
        return
      end
      i32.const 71
      call $__wasi_proc_exit
      unreachable
    end
    i32.const 71
    call $__wasi_proc_exit
    unreachable)
  (func $dummy (type $t2)
    nop)
  (func $libc_exit_fini (type $t2)
    call $dummy)
  (func $exit (type $t1) (param $p0 i32)
    call $dummy
    call $libc_exit_fini
    call $dummy
    local.get $p0
    call $_Exit
    unreachable)
  (func $_Exit (type $t1) (param $p0 i32)
    local.get $p0
    call $__wasi_proc_exit
    unreachable)
  (func $_emscripten_stack_restore (type $t1) (param $p0 i32)
    local.get $p0
    global.set $__stack_pointer)
  (func $emscripten_stack_get_current (type $t4) (result i32)
    global.get $__stack_pointer)
  (table $__indirect_function_table 6 6 funcref)
  (memory $memory 258 258)
  (global $__stack_pointer (mut i32) (i32.const 66608))
  (export "memory" (memory $memory))
  (export "__indirect_function_table" (table $__indirect_function_table))
  (export "_start" (func $_start))
  (export "_emscripten_stack_restore" (func $_emscripten_stack_restore))
  (export "emscripten_stack_get_current" (func $emscripten_stack_get_current))
  (elem $e0 (i32.const 1) func $A::method__ $B::method__ $C::method__ $D::method__ $__wasm_call_ctors)
  (data $.rodata (i32.const 1032) "\01")
  (data $.rodata.1 (i32.const 1044) "\02")
  (data $.rodata.2 (i32.const 1056) "\03")
  (data $.rodata.3 (i32.const 1068) "\04"))
