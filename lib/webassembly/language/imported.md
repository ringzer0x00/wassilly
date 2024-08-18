# How to specify imported function behavior:
An imported `func` is described by a pre-condition and a post-condition.
Both pre and post conditions might operate on multiple levels:
    - they may or may not relate to input/output values with respect to the execution of `func`
    - they may or may not relate to modifications performed in both exported and imported elements 
        (globals, memories, tables)
    - both pre and post-conditions need to have some form of way to define "everything goes beahvior" 
        (e.g. all of the shared memory is set to Top), and "this function accepts any value". 
        Pre-conditions act as CONSTRAINTS, if they are absent, anything goes.
        Post-conditions act as a response to pre-conditions, if a bound is absent it acts as identity.


Example:

imported func ( $myfunc ($l0_i32 -> $l1_i32) -> void )
`pre: $l0_i32 >= 0` ## meaning: nothing is bound except for $l0_i32
`post: memory[$l0_i32]=42` ## the memory at abstract offset $l0_i32 is set to 42
