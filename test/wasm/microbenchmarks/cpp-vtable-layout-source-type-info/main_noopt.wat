(module $main_noopt.wasm
  (type $t0 (func (param i32) (result i32)))
  (type $t1 (func))
  (type $t2 (func (result i32)))
  (type $t3 (func (param i32)))
  (type $t4 (func (param i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "args_sizes_get" (func $__wasi_args_sizes_get (type $t4)))
  (import "wasi_snapshot_preview1" "args_get" (func $__wasi_args_get (type $t4)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $__wasi_proc_exit (type $t3)))
  (func $__wasm_call_ctors (type $t1)
    call $emscripten_stack_init)
  (func $module1_bool_ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32) (local $l11 i32) (local $l12 i32) (local $l13 i32) (local $l14 i32) (local $l15 i32) (local $l16 i32) (local $l17 i32) (local $l18 i32) (local $l19 i32) (local $l20 i32) (local $l21 i32) (local $l22 i32) (local $l23 i32) (local $l24 i32) (local $l25 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    global.set $__stack_pointer
    local.get $p0
    local.set $l4
    local.get $l3
    local.get $l4
    i32.store8 offset=15
    i32.const 8
    local.set $l5
    local.get $l3
    local.get $l5
    i32.add
    local.set $l6
    local.get $l6
    local.set $l7
    local.get $l7
    call $A::A__
    drop
    i32.const 4
    local.set $l8
    local.get $l3
    local.get $l8
    i32.add
    local.set $l9
    local.get $l9
    local.set $l10
    local.get $l10
    call $B::B__
    drop
    local.get $l3
    i32.load8_u offset=15
    local.set $l11
    i32.const 1
    local.set $l12
    local.get $l11
    local.get $l12
    i32.and
    local.set $l13
    block $B0
      block $B1
        local.get $l13
        i32.eqz
        br_if $B1
        i32.const 8
        local.set $l14
        local.get $l3
        local.get $l14
        i32.add
        local.set $l15
        local.get $l15
        local.set $l16
        local.get $l3
        local.get $l16
        i32.store
        br $B0
      end
      i32.const 4
      local.set $l17
      local.get $l3
      local.get $l17
      i32.add
      local.set $l18
      local.get $l18
      local.set $l19
      local.get $l3
      local.get $l19
      i32.store
    end
    local.get $l3
    i32.load
    local.set $l20
    local.get $l20
    i32.load
    local.set $l21
    local.get $l21
    i32.load
    local.set $l22
    local.get $l20
    local.get $l22
    call_indirect $__indirect_function_table (type $t0)
    local.set $l23
    i32.const 16
    local.set $l24
    local.get $l3
    local.get $l24
    i32.add
    local.set $l25
    local.get $l25
    global.set $__stack_pointer
    local.get $l23
    return)
  (func $A::A__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    local.get $l3
    i32.load offset=12
    local.set $l4
    i32.const 65536
    local.set $l5
    i32.const 8
    local.set $l6
    local.get $l5
    local.get $l6
    i32.add
    local.set $l7
    local.get $l4
    local.get $l7
    i32.store
    local.get $l4
    return)
  (func $B::B__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    global.set $__stack_pointer
    local.get $l3
    local.get $p0
    i32.store offset=12
    local.get $l3
    i32.load offset=12
    local.set $l4
    local.get $l4
    call $A::A__
    drop
    i32.const 65548
    local.set $l5
    i32.const 8
    local.set $l6
    local.get $l5
    local.get $l6
    i32.add
    local.set $l7
    local.get $l4
    local.get $l7
    i32.store
    i32.const 16
    local.set $l8
    local.get $l3
    local.get $l8
    i32.add
    local.set $l9
    local.get $l9
    global.set $__stack_pointer
    local.get $l4
    return)
  (func $module2_bool_ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32) (local $l11 i32) (local $l12 i32) (local $l13 i32) (local $l14 i32) (local $l15 i32) (local $l16 i32) (local $l17 i32) (local $l18 i32) (local $l19 i32) (local $l20 i32) (local $l21 i32) (local $l22 i32) (local $l23 i32) (local $l24 i32) (local $l25 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    global.set $__stack_pointer
    local.get $p0
    local.set $l4
    local.get $l3
    local.get $l4
    i32.store8 offset=15
    i32.const 8
    local.set $l5
    local.get $l3
    local.get $l5
    i32.add
    local.set $l6
    local.get $l6
    local.set $l7
    local.get $l7
    call $C::C__
    drop
    i32.const 4
    local.set $l8
    local.get $l3
    local.get $l8
    i32.add
    local.set $l9
    local.get $l9
    local.set $l10
    local.get $l10
    call $D::D__
    drop
    local.get $l3
    i32.load8_u offset=15
    local.set $l11
    i32.const 1
    local.set $l12
    local.get $l11
    local.get $l12
    i32.and
    local.set $l13
    block $B0
      block $B1
        local.get $l13
        i32.eqz
        br_if $B1
        i32.const 8
        local.set $l14
        local.get $l3
        local.get $l14
        i32.add
        local.set $l15
        local.get $l15
        local.set $l16
        local.get $l3
        local.get $l16
        i32.store
        br $B0
      end
      i32.const 4
      local.set $l17
      local.get $l3
      local.get $l17
      i32.add
      local.set $l18
      local.get $l18
      local.set $l19
      local.get $l3
      local.get $l19
      i32.store
    end
    local.get $l3
    i32.load
    local.set $l20
    local.get $l20
    i32.load
    local.set $l21
    local.get $l21
    i32.load
    local.set $l22
    local.get $l20
    local.get $l22
    call_indirect $__indirect_function_table (type $t0)
    local.set $l23
    i32.const 16
    local.set $l24
    local.get $l3
    local.get $l24
    i32.add
    local.set $l25
    local.get $l25
    global.set $__stack_pointer
    local.get $l23
    return)
  (func $C::C__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    local.get $l3
    i32.load offset=12
    local.set $l4
    i32.const 65560
    local.set $l5
    i32.const 8
    local.set $l6
    local.get $l5
    local.get $l6
    i32.add
    local.set $l7
    local.get $l4
    local.get $l7
    i32.store
    local.get $l4
    return)
  (func $D::D__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    global.set $__stack_pointer
    local.get $l3
    local.get $p0
    i32.store offset=12
    local.get $l3
    i32.load offset=12
    local.set $l4
    local.get $l4
    call $C::C__
    drop
    i32.const 65572
    local.set $l5
    i32.const 8
    local.set $l6
    local.get $l5
    local.get $l6
    i32.add
    local.set $l7
    local.get $l4
    local.get $l7
    i32.store
    i32.const 16
    local.set $l8
    local.get $l3
    local.get $l8
    i32.add
    local.set $l9
    local.get $l9
    global.set $__stack_pointer
    local.get $l4
    return)
  (func $main (type $t4) (param $p0 i32) (param $p1 i32) (result i32)
    (local $l2 i32) (local $l3 i32) (local $l4 i32) (local $l5 i32) (local $l6 i32) (local $l7 i32) (local $l8 i32) (local $l9 i32) (local $l10 i32) (local $l11 i32) (local $l12 i32) (local $l13 i32) (local $l14 i32) (local $l15 i32) (local $l16 i32) (local $l17 i32) (local $l18 i32) (local $l19 i32) (local $l20 i32)
    global.get $__stack_pointer
    local.set $l2
    i32.const 16
    local.set $l3
    local.get $l2
    local.get $l3
    i32.sub
    local.set $l4
    local.get $l4
    global.set $__stack_pointer
    i32.const 0
    local.set $l5
    local.get $l4
    local.get $l5
    i32.store offset=12
    local.get $l4
    local.get $p0
    i32.store offset=8
    local.get $l4
    local.get $p1
    i32.store offset=4
    local.get $l4
    i32.load offset=8
    local.set $l6
    i32.const 1
    local.set $l7
    local.get $l6
    local.get $l7
    i32.gt_s
    local.set $l8
    i32.const 1
    local.set $l9
    local.get $l8
    local.get $l9
    i32.and
    local.set $l10
    local.get $l10
    call $module1_bool_
    local.set $l11
    local.get $l4
    i32.load offset=8
    local.set $l12
    i32.const 1
    local.set $l13
    local.get $l12
    local.get $l13
    i32.gt_s
    local.set $l14
    i32.const 1
    local.set $l15
    local.get $l14
    local.get $l15
    i32.and
    local.set $l16
    local.get $l16
    call $module2_bool_
    local.set $l17
    local.get $l11
    local.get $l17
    i32.add
    local.set $l18
    i32.const 16
    local.set $l19
    local.get $l4
    local.get $l19
    i32.add
    local.set $l20
    local.get $l20
    global.set $__stack_pointer
    local.get $l18
    return)
  (func $A::method__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    i32.const 23
    local.set $l4
    local.get $l4
    return)
  (func $B::method__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    i32.const 42
    local.set $l4
    local.get $l4
    return)
  (func $C::method__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    i32.const 1
    local.set $l4
    local.get $l4
    return)
  (func $D::method__ (type $t0) (param $p0 i32) (result i32)
    (local $l1 i32) (local $l2 i32) (local $l3 i32) (local $l4 i32)
    global.get $__stack_pointer
    local.set $l1
    i32.const 16
    local.set $l2
    local.get $l1
    local.get $l2
    i32.sub
    local.set $l3
    local.get $l3
    local.get $p0
    i32.store offset=12
    i32.const 2
    local.set $l4
    local.get $l4
    return)
  (func $_start (type $t1)
    block $B0
      i32.const 5
      i32.eqz
      br_if $B0
      call $__wasm_call_ctors
    end
    call $__main_void
    call $exit
    unreachable)
  (func $__main_void (type $t2) (result i32)
    (local $l0 i32) (local $l1 i32) (local $l2 i32) (local $l3 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee $l0
    global.set $__stack_pointer
    block $B0
      block $B1
        local.get $l0
        local.tee $l1
        i32.const 12
        i32.add
        local.get $l1
        i32.const 8
        i32.add
        call $__wasi_args_sizes_get
        br_if $B1
        block $B2
          block $B3
            local.get $l1
            i32.load offset=12
            local.tee $l2
            br_if $B3
            i32.const 0
            local.set $l2
            i32.const 0
            local.set $l0
            br $B2
          end
          local.get $l0
          local.get $l2
          i32.const 2
          i32.shl
          local.tee $l2
          i32.const 19
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee $l0
          local.tee $l3
          global.set $__stack_pointer
          local.get $l3
          local.get $l1
          i32.load offset=8
          i32.const 15
          i32.add
          i32.const -16
          i32.and
          i32.sub
          local.tee $l3
          global.set $__stack_pointer
          local.get $l0
          local.get $l2
          i32.add
          i32.const 0
          i32.store
          local.get $l0
          local.get $l3
          call $__wasi_args_get
          br_if $B0
          local.get $l1
          i32.load offset=12
          local.set $l2
        end
        local.get $l2
        local.get $l0
        call $main
        local.set $l0
        local.get $l1
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
  (func $dummy (type $t1))
  (func $libc_exit_fini (type $t1)
    (local $l0 i32)
    i32.const 0
    local.set $l0
    block $B0
      i32.const 0
      i32.const 0
      i32.le_u
      br_if $B0
      loop $L1
        local.get $l0
        i32.const -4
        i32.add
        local.tee $l0
        i32.load
        call_indirect $__indirect_function_table (type $t1)
        local.get $l0
        i32.const 0
        i32.gt_u
        br_if $L1
      end
    end
    call $dummy)
  (func $exit (type $t3) (param $p0 i32)
    call $dummy
    call $libc_exit_fini
    call $dummy
    local.get $p0
    call $_Exit
    unreachable)
  (func $_Exit (type $t3) (param $p0 i32)
    local.get $p0
    call $__wasi_proc_exit
    unreachable)
  (func $emscripten_stack_init (type $t1)
    i32.const 65536
    global.set $__stack_base
    i32.const 0
    i32.const 15
    i32.add
    i32.const -16
    i32.and
    global.set $__stack_end)
  (func $emscripten_stack_get_free (type $t2) (result i32)
    global.get $__stack_pointer
    global.get $__stack_end
    i32.sub)
  (func $emscripten_stack_get_base (type $t2) (result i32)
    global.get $__stack_base)
  (func $emscripten_stack_get_end (type $t2) (result i32)
    global.get $__stack_end)
  (func $_emscripten_stack_restore (type $t3) (param $p0 i32)
    local.get $p0
    global.set $__stack_pointer)
  (func $emscripten_stack_get_current (type $t2) (result i32)
    global.get $__stack_pointer)
  (table $__indirect_function_table 6 6 funcref)
  (memory $memory 258 258)
  (global $__stack_pointer (mut i32) (i32.const 65536))
  (global $__stack_end (mut i32) (i32.const 0))
  (global $__stack_base (mut i32) (i32.const 0))
  (export "memory" (memory $memory))
  (export "__indirect_function_table" (table $__indirect_function_table))
  (export "_start" (func $_start))
  (export "emscripten_stack_init" (func $emscripten_stack_init))
  (export "emscripten_stack_get_free" (func $emscripten_stack_get_free))
  (export "emscripten_stack_get_base" (func $emscripten_stack_get_base))
  (export "emscripten_stack_get_end" (func $emscripten_stack_get_end))
  (export "_emscripten_stack_restore" (func $_emscripten_stack_restore))
  (export "emscripten_stack_get_current" (func $emscripten_stack_get_current))
  (elem $e0 (i32.const 1) func $A::method__ $B::method__ $C::method__ $D::method__ $__wasm_call_ctors)
  (data $.rodata (i32.const 65536) "\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00\00\00\00\02\00\00\00\00\00\00\00\00\00\00\00\03\00\00\00\00\00\00\00\00\00\00\00\04\00\00\00"))
