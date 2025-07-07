To run `sturdy` form the container run it intereactively and run the commands:
```
sbt compile
sbt "testOnly sturdy.language.wasm.simple.ToughCallIntervalControlEventTest"
```

# How to read the results:
This is an example of output (for direct-call-simple) (see also what is after the comments ##):

```
Unfailing(List()) ## <- information about the analysis results (i.e. errors)
Reachable functions (2): 4a8f7a6e.0, 4a8f7a6e.1
Call edges (1): 
  (4a8f7a6e.0,4a8f7a6e.1)
/sturdy.scala/sturdy-wasm/target/scala-3.3.5/test-classes/sturdy/language/wasm/thatsatoughcall/microbenchmarks/direct-call-simple/main.wasm.interval.dot ## <- the last directory helps identify the test case of interest
```

In particular, the reachable function are split into `hash.function_index` or `host_env.function_index`. So, the set of reachable functions for this test is {0;1} and the edges are {(0,1)}. The hash or host_env parts of the vertices can be safely ignored, as WASM indexes each function uniquely, it does not matter if it is a host or module function.

These vertices/edges can be compared to the results of `/wassilly/test/cg_closed.ml` and `/wassilly/test/cg_open.ml`, that contain the expected behavior of `wassilly` when performing the analysis.