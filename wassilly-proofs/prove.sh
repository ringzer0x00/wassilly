lean prova.lean
if [ $? -eq 0 ]
then
	echo "Yay! Proofs compiled correctly!"
	exit 0
else
	echo "Proofs gave errors!!! :("
	exit 1
fi
