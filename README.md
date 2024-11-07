# wassilly
WebAssembly Ain't So SILLY

Artifact for the paper `Hybrid Call Graph Analysis for WebAssembly: Combining Abstract Interpretation and Specification in the Pursue of Soundness` by Mattia Paccamiccio, Franco Raimondi, Michele Loreti.

For installation instruction see INSTALL.md.

To run the evaluation benchmarks run `dune test`.
The testfiles of interest are `cg_open.ml` and `cg_closed.ml`.
Note that the test `cpp-vtable-layout-source-type-info` will take a long time (and memory) due to inefficiencies in how the linear memory is represented.