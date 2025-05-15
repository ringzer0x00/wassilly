# Development of `wassilly`

Install Opam dependencies, apply your modifications, then re-compile it with 

`dune build`

and run it with `./_build/default/bin/main.exe [...]`.

Other ways include re-install the modified package with `opam install .` but, as it requires a bit more nuance, the relevant Opam documentation should be consulted.

## Project structure

``.``  
``├── bin`` -> **analyzer front-end**  
``├── lib`` -> **libraries**  
``│   ├── ds`` -> **data structures**  
``│   ├── importspec`` -> **specification engine language and parser**  
``│   ├── utilities`` -> **helper functions and configuration**  
``│   └── webassembly``  
``│       ├── fixpointlogic`` -> **logic for the fix point algorithm**  
``│       ├── interpreter`` -> **interpreter logic and semantics**  
``│       ├── language`` -> **definition of some language-specific types**  
``│       └── memories`` -> **definition of the possible memories (stack, linearmemory, etc.)**  
``├── replication`` -> **files related to the replication process**  
``├── test`` -> **test cases**
