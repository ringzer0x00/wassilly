# wassilly
WebAssembly Ain't So SILLY

Artifact for the paper `Hybrid Call Graph Analysis for WebAssembly: Combining Abstract Interpretation and Specification in the Pursuit of Soundness`.

For installation instructions see [INSTALL.md](https://github.com/ringzer0x00/wassilly/blob/master/INSTALL.md).

# REPLICATION INSTRUCTIONS

### Tool replication
To run the benchmarks from the paper:

> `make wassilly-replicate` or `make`

from the main directory. This **might** require root privileges. It will build a Docker container and run the replication tests. For better visualization of the table of experiments it is suggested to expand the terminal.

### Run mechanized proofs
