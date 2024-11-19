On Ubuntu:
```
sudo apt-get install --no-install-recommends opam   #if opam not installed
sudo apt-get install m4 autoconf libgmp-dev libmpfr-dev -y
opam init -y    #if opam not initialized
eval $(opam env --switch=default)
opam install .
wassilly [...]
```

Dockerfile is available.
```
docker build . -t wassilly
docker run -it --rm wassilly
wassilly [...]
```

For ARM machines:
``
docker build --platform linux/amd64 . -t wassilly
``