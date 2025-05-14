name := lean

all: build prove
build: 
	docker build . -t $(name)
prove:
	docker run -it --rm $(name) sh /wassilly-proofs/prove.sh
