#!/bin/bash

. /etc/profile

cd ~/router; git pull > /dev/null

BSN=$1
FIRST=$2
LAST=$3
declare -a ARRAY

pause() {
	OLDCONFIG=`stty -g`
	stty -icanon -echo min 1 time 0
	dd count=1 2>/dev/null
	stty $OLDCONFIG
}

display_rmserver() {
	echo "I'm going to do the following on $NS"
        echo -e "----------\n"
        echo "ssh nsroot@$NS rm server $HN"	
}

cleanvips() {
   ping -c5 $HN > /dev/null 2>&1

   if [ $? -ne 0 ];then
	echo -e "\n*** $HN is not pingable, good to go ahead. ***\n"
	AN=Y
   else
	echo
	read -p "$HN is pingable, are you sure to proceed?" AN
   fi

   if [ $AN != 'Y' ];then
	exit 1
   fi

   echo -e "\n$HN is currently bound to the following VIPs:\n------------\n"

   grep ${HN}- * |grep vserver

   echo

   read -p "Are the VIPs listed above correct?" AN

   echo

   if [ $AN == 'Y' ];then
      #
      # get the netscalers where the host is on
      #
      NS=`grep ${HN}- * |grep vserver|awk -F ':' '{print $1}' | uniq`
      
      for NN in `echo $NS`
      do 
	let "i = 0"
	#
	# show members of the VIP
	#	
	for VIP in $(grep ${HN}- $NN |grep vserver | awk '{print $4}')
	do
		echo "The current configuration(s) of $VIP on $NN is:"
		ssh -o stricthostkeychecking=no nsroot@$NN sh lb vserver $VIP
		echo -e "\n-----------------\n"	
		
		ST=N
		ST=`ssh -o stricthostkeychecking=no nsroot@$NN sh lb vserver $VIP 2>/dev/null | grep 'Effective State:' |awk '{print $3}'` 2>/dev/null

		if [ $ST != 'UP' ];then
			ARRAY[$i]=$VIP
			let "i += 1"
		fi
		sleep 3
	done

	echo
	echo "You can issue the commands manually on $NN"
	echo "-----------------"
	echo "rm server $HN"
	for item in ${ARRAY[*]}
	do
		 echo "rm lb vserver $item"
      	done

	unset ARRAY
	echo
	echo -e "\n\n@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
      done
    fi
}

#
# main
#
for i in `seq ${FIRST} ${LAST}`
do
	HN=${BSN}$i
	# echo $HN
	cleanvips 
	echo -e "\n+++++++++++++++++++++++++++++++++++++++++++++++\n\n"
	echo "Hit a key to continue ..."
	pause
done

exit 0
