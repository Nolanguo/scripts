#!/bin/bash

. /etc/profile

if [ "$#" -ne 1 ]
then
        echo "A file containing hostnames must be supplied."
        exit 3
fi

exec 8<$1

while read -u 8 HS
do
	echo $HS
	for hm in pradhant posborne tlosborne wpang
	do 
		echo $hm
		ssh $HS sudo mkdir -p /mnt/home/$hm
		ssh $HS sudo chown ${hm} /mnt/home/$hm
	done
	ssh $HS sudo mount -t nfs phx1-ito-filer2.nguo.com:/vol/homedir1/home/wpang /mnt/home/wpang
	ssh $HS sudo mount -t nfs cn-bos1-homedir-filer1.nguo.com:/vol/unix1/homedir1/ma/pradhant /mnt/home/pradhant
	ssh $HS sudo mount -t nfs c17-sha-homedir-filer1.nguo.com:/vol/vol0/home/sf/posborne /mnt/home/posborne
	ssh $HS sudo mount -t nfs c17-sha-homedir-filer1.nguo.com:/vol/vol0/home/sf/tlosborne /mnt/home/tlosborne 
done

exit 0
