FROM ubuntu:24.10

RUN apt-get update
RUN apt-get install opam -y
RUN apt-get install m4 ca-certificates -y
RUN apt-get install git -y
RUN opam init --disable-sandboxing
RUN eval "eval $(opam env --switch=default)" && opam update -y
RUN apt-get install autoconf libgmp-dev libmpfr-dev -y
WORKDIR wassilly
ADD . .
RUN eval "eval $(opam env --switch=default)" && opam install . -y
#RUN eval "$(opam env)" && opam update && opam install dune && opam install .
# ["opam", "exec", "--"]
CMD ["/bin/bash"]
#docker run -it --rm <containter> sh 
#dune test