FROM ocaml/opam:ubuntu-lts-ocaml-5.0

RUN sudo apt-get update
RUN sudo apt-get -y install pkg-config libgmp-dev libmpfr-dev git
RUN opam update
RUN opam install dune 
RUN opam install ocamlfind 
RUN opam install camlidl 
RUN opam install mlgmpidl 
RUN opam install apron 
RUN opam install ounit2
RUN eval $(opam env)

WORKDIR wassilly
ADD . .
RUN sudo chown -R opam:nogroup .
ENTRYPOINT ["opam", "exec", "--"]

#docker run -it --rm <containter> sh 
#dune test