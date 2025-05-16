# wassilly
WebAssembly Ain't So SILLY

Artifact for the paper `Hybrid Call Graph Analysis for WebAssembly: Combining Abstract Interpretation and Specification in the Pursuit of Soundness`.

- For instructions regarding the replication of experiments and proofs, see [Replication](#replication).
- For instructions on general usage of `wassilly`, see [`./wassilly/README.md`](./wassilly/README.md).
- For instructions on developing on top of `wassilly`, see [Development](#development).
- For installation instructions see [`./wassilly/INSTALL.md`](./wassilly/INSTALL.md).

# Replication
Dependencies: `docker`, `make`.

The replication packages are built with Docker and use auxiliary Makefiles to ease the setup.

**`docker build` runs with the --quiet flag!** It may take a while, but it should **not** get stuck.

> **Makefiles:** [`./Makefile`](./Makefile), [`./wassilly/Makefile`](./wassilly/Makefile), [`./wassilly-proofs/Makefile`](./wassilly-proofs/Makefile).

### Experiments replication
To run the benchmarks from the paper:

`make benchmarks`

from the root directory. This **might** require root privileges. It will build a dedicated Docker container with the OCaml toolchain, libraries etc. and run the replication tests. For better visualization of the table of experiments it is suggested to expand the terminal.

#### How to read the experiments
You can find 4 columns in the output: TestCase, S, C, E representing, respectively: the benchmark name (benchmarks from *Lehmann et al.* referenced in the paper), **S** for Soundness, **C** for Completeness, and **E** for Exact, as in both Sound and Complete analysis results.

The ground truth for the reachable call graph can be found (encoded) in [`./wassilly/replication/ground_truths.ml`](./wassilly/replication/ground_truths.ml)
and the original ones provided in *Lehman et al.* in [`./wassilly/replication/microbenchmarks-ground-truths.json`](./wassilly/replication/microbenchmarks-ground-truth.json)

---

*The build needs some time to finish (**~10-15 minutes**) due to project dependencies, so I suggest you grab some coffee, listen to some music, or maybe play with your dog or cat!*

---

# Development
See [./wassilly/DEV.md](./wassilly/DEV.md).