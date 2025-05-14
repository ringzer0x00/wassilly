tool := wassilly
cmd := dune runtest replication
quiet := --quiet

wassilly-replicate: wassilly-build wassilly-replication-tests

wassilly-build:
	docker build $(quiet) . -t $(tool)

wassilly-run:
	docker run --platform linux/amd64 -it --rm $(tool)

wassilly-replication-tests:
	docker run --platform linux/amd64 -it --rm -e PATH='/root/.opam/default/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' $(tool) $(cmd)
