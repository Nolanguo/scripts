#!/bin/bash

. /etc/profile

HOST=`machines --pingable $1`

echo $HOST

read -p "Are the hosts listed above correct?" A1

if [ $A1 == "Y" ]
then
	for h in $HOST
	do
		echo "----- $h ----"
		ssh -o Stricthostkeychecking=no $h id $2
		echo 
	done
fi

exit
