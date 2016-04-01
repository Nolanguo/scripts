#!/bin/bash

GW=$(netstat -rn | grep default | grep en | awk '{print $2}')

remove_route() {
	sudo route delete -net 140.205
	sudo route delete -net 110.75
	sudo route delete -net 121.43
	sudo route delete -host 121.40.69.89
	sudo route delete -host 118.26.142.175
}

add_route() {
	sudo route add -net 140.205 $GW
	sudo route add -net 110.75 $GW
	sudo route add -net 121.43 $GW
	sudo route add -host 121.40.69.89 $GW
	sudo route add -host 118.26.142.175 $GW
}

if [ $# -eq 1 ];
then
	ACTION=$1
else
	ACTION='null'
fi

if [ $ACTION == 'rm' ];
then
	remove_route
elif [ $ACTION == 'add' ];
then
	add_route
else
	remove_route && add_route
fi

exit 0
