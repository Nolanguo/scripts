for ((i=1;i-16;i++)) 
do
	echo "`expr $i + 74`      IN      PTR     phx2-ccs-col-wax${i}.nguo.com."
done

for ((i=1;i-16;i++))
do
	echo "phx2-ccs-col-wax${i}	 IN      A       10.14.162.`expr $i + 74`"
done
