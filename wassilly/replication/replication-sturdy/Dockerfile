FROM --platform=linux/amd64 ubuntu:24.10

RUN apt-get update --fix-missing
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get -qq -y install curl wget unzip zip git
RUN curl -s "https://get.sdkman.io" | bash
RUN git clone https://gitlab.rlp.net/plmz/sturdy.scala
RUN source "$HOME/.sdkman/bin/sdkman-init.sh" \
    && sdk install java 17.0.14-tem \
    && sdk install sbt  \
    && sdk install scala
WORKDIR /sturdy.scala
RUN apt-get -y install gcc libgmp-dev libmpfr-dev make
RUN git clone https://github.com/antoinemine/apron \
    && cd apron \
    && ./configure -no-cxx -no-ppl -no-pplite -no-ocaml --ext-dll dylib \
    && make \
    && make install
RUN mkdir /sturdy.scala/sturdy-apron/lib_extra/unix-amd64
RUN cp /usr/local/lib/libapron.a /sturdy.scala/sturdy-apron/lib_extra/unix-amd64/
# sbt compile
# sbt "testOnly sturdy.language.wasm.simple.ToughCallIntervalControlEventTest"

CMD ["/bin/bash"]