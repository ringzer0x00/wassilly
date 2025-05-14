FROM --platform=linux/amd64 ubuntu:24.10

RUN apt-get update
WORKDIR wassilly-proofs
ADD . .
RUN apt-get -y install apt-utils
RUN apt-get -y install git curl
RUN curl https://elan.lean-lang.org/elan-init.sh -o elan-init.sh
RUN chmod +x elan-init.sh
RUN ./elan-init.sh -y
ENV PATH="$PATH:/root/.elan/bin"
RUN elan self update
RUN elan default leanprover/lean4:stable
#RUN lean -h
RUN chmod +x prove.sh
#RUN sh prove.sh

CMD ["/bin/bash"]

