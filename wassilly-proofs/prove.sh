lean prova.lean
if [ $? -eq 0 ]
then
	echo "\e[32mYay! Proofs compiled correctly!\e[0m"
	exit 0
else
	echo "\e[31mProofs gave errors!!! :(\e[0m"
	exit 1
fi
