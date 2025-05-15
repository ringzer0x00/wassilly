# wassilly - How to install

We offer two main ways of installing `wassilly`:

## on Docker
### with Make
- build: `make wassilly-build`
- and run: `docker run --platform linux/amd64 -it --rm wassilly`

## on Ubuntu
To install `wassilly` on Ubuntu run the following commands:
```
sudo apt-get install --no-install-recommends opam           #if opam not installed
sudo apt-get install m4 autoconf libgmp-dev libmpfr-dev -y
opam init -y                                                #if opam not initialized
eval $(opam env --switch=default)
opam install .
```

This will take care of the dependencies and install `wassilly` as `opam` package. It can then be run with `wassilly [...]`.