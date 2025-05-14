name := lean

build: 
	docker build . -t $(name)
prove:
	docker run -it --rm $(name) sh /wassilly-proofs/prove.sh

all: build prove