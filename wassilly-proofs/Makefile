name := lean
quiet := --quiet

all: build prove
build: 
	docker build $(quiet) . -t $(name)
prove:
	docker run --platform linux/amd64 -it --rm $(name) sh /wassilly-proofs/prove.sh
