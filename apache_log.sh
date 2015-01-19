#!/bin/bash

. /etc/profile

zcat $1 | awk '{print $NF}' | uniq > /tmp/$$.tmp

exec 8< /tmp/$$.tmp

while read line < &8
do
	zcat $1 |grep $line | sort |uniq -c -w 15|sort -n|awk '{print $1\t$2\t$NF}'
	echo "--------------------------------------------------------------------"
done

exit 0
