default:
	@echo "Select an option."
	@echo -e "i.e.: run \033[1mmake benchmarks\033[0m or \033[1mmake proofs\033[0m."
	exit 1

benchmarks:
	make -C wassilly/ wassilly-replicate

proofs:
	make -C wassilly-proofs/ all