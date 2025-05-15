# Development of `wassilly`

Install Opam dependencies, apply your modifications, then re-compile it with 

`dune build`

and run it with `./_build/default/bin/main.exe [...]`.

## Project structure

``.``  
``├── bin`` -> **program entry point**  
``├── lib``  
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
