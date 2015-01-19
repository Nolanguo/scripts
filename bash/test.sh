        read -p "Are the hosts listed above correct? [N]" A1
	
if test -z $A1
then
A1=N
fi

        if [ $A1 != "Y" ]
        then
                echo "Hostnames have some problems!"
                exit 44
        fi
