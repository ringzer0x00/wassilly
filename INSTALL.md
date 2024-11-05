``
sudo apt-get install --no-install-recommends opam
opam init -y
eval $(opam env --switch=default)
opam install .
wassilly $HOME/wassilly-master/test/wasm/microbenchmarks/direct-call-simple/main.wasm -o ciao.dot
``