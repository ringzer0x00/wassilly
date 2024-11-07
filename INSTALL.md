On Ubuntu:
```
sudo apt-get install --no-install-recommends opam
opam init -y
eval $(opam env --switch=default)
opam install .
wassilly [...]
```

External dependencies may be needed, but opam will help! :)

Dockerfile is available.