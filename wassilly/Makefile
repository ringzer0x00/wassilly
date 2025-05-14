tool := wassilly

wassilly-replicate: wassilly-build wassilly-replication-tests

wassilly-build:
	docker build . -t $(tool)

wassilly-run:
	docker run --platform linux/amd64 -it --rm $(tool)

wassilly-replication-tests:
# replace with docker run ...
	docker run --platform linux/amd64 -it --rm $(tool) dune runtest replication
