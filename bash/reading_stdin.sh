#!/bin/bash

. /etc/profile

while read HS
do
	H=`echo $HS| tr '\n' ' '`
	HSS=$HSS$H
done

echo $HSS

exit 0

