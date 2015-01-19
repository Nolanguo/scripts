#!/bin/bash

. /etc/profile

if [ "$#" -ne 1 ]
then
	echo "A file containing hostnames must be supplied."
	exit 3
fi

exec 8<$1

while read <8 HS
do
	ssh $HS sudo fio-status |grep Firmware
	ssh $HS sudo rpm -Uvh 'http://c17-nasa-colo-master1.nguo.com/linux/vendor/FusionIO/ioDrive/fio-firmware-101971.4-1.0.noarch.rpm'
	ssh $HS sudo umount /var/hot1
	ssh $HS sudo fio-detach /dev/fct0
	ssh $HS sudo fio-update-iodrive -d /dev/fct0 /usr/share/fio/firmware/iodrive_*.fff
	ssh $HS sudo reboot	
	while ! ping -c1 $HS
	do 
		sleep 30
	done
	ssh $HS sudo fio-status |grep Firmware
done

exit 0
