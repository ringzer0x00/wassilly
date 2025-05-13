hello:
	echo "Hello, World"

dockerbuild:
	docker build . -t wassilly

dockerrun:
	docker run --platform linux/amd64 -it --rm wassilly

sas-replication:
	dune runtest replication