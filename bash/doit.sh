#!/bin/bash

. /etc/profile

#
# Function to generate a list of hostnames
get_host_list() {
	H=$1
	BASENAME=`echo $H | cut -d '[' -f1`
	S2=`echo $H | cut -d '[' -f2 | sed 's/,/\ /g'`
	END=''
	for sss in $S2
	do
		sss=`echo $sss | sed 's/\]//g'`
		if [[ $sss == *-* ]]
		then
			start=`echo $sss | cut -d '-' -f1`
			end=`echo $sss | cut -d '-' -f2`
			END=$END' '`seq $start $end`
		else
			END=$END' '$sss
		fi
	done

	for f in $END
	do
		HSS=${HSS}${BASENAME}$f' '
	done
}

#
# Function print_usage
print_usage() {
	echo 
	echo "Usage:  `basename $0` [ -i APP | <-a|-u> username | -c <command on remote hosts> | -g | -H <hostnames> | -s | -q ]  [command on local]"
	echo -ne "\nThis script will show uptime of the hosts, if no options are given.\n"
	echo -ne "\nThe Options are:\n"
	echo -ne "\t-i:    Install APP on given hosts. where APP are one of:\n"
	echo -ne "\t\tnrpe\t#install nrpe on client hosts.\n"
	echo -ne "\t\tvmt\t#install VMware tools on VM guest hosts.\n\n"
	echo -ne "\t-u:    Check if the user exists on given hosts.\n\n"
	echo -ne "\t-a:    Create account for username on given hosts.\n\n"
	echo -ne "\t-g:    Generate CSR for given CN.\n\n"
	echo -ne "\t-H:    followed by hostnames, in the form of HOSTNAME[1,3-5,6]\n\n"
	exit $E_INVOKERROR
}

#
# Function to remount /var/opt
remount_var_opt() {
	local HOST=$@
        get_host_list
        for i in $HOST
        do
                echo "---- $i -----"
                ssh -o StrictHostkeyChecking=no $i "	
sudo /sbin/mkfs.ext3 /dev/sdb1
sudo mount /dev/sdb1 /mnt/
sudo rsync -avH /var/opt/ /mnt/
sudo umount /mnt
sudo sed -i.orig -e '$a/dev/sdb1               /var/opt                    ext3    defaults        1 2' /etc/fstab
sudo mv /var/opt /var/opt.old
sudo mkdir /var/opt
sudo mount -a
sudo /sbin/restorecon -R -v /var/opt
df -h"
		echo
	done
}

#
# Function to install VMware_tools
install_VMware_tools() {
	local HOST=$@
	get_host_list
	for i in $HOST
	do
		echo "---- $i -----"
		ssh -o StrictHostkeyChecking=no $i "
sudo mount /dev/cdrom /mnt
cd /mnt
sudo tar xzvf /mnt/VMwareTools*.tar.gz -C /root/.
sudo /root/vmware-tools-distrib/vmware-install.pl --default
sudo sed -i.orig -e 's/eth0 e1000/eth0 vmxnet/' /etc/modprobe.conf
sudo /sbin/chkconfig ether-100-full off
sudo rm -rf /root/vmware-tools-distrib
sudo reboot"
		echo
	done
}

#
# Function to install nrpe
install_nrpe() {
	local HOST=$@
	get_host_list
        for i in $HOST
        do
                echo "---- $i -----"
                ssh -o StrictHostkeyChecking=no $i "
sudo -u deploy /opt/tools/bin/ezdeploy -f -s nguo-nagios-nrpe
sudo -u deploy rpm -Uvh --nodeps http://rpm.nguo.com/rpm/third_party/nguo-nagios/plugins/nguo-nagios-plugins-1.4.14-2_64el5.x86_64.rpm
sudo -u deploy rpm -Uvh http://rpm.nguo.com/rpm/third_party/nguo-nagios/plugins/nguo-nagios-plugins-default-1.4.14-2_64el5.x86_64.rpm
sudo -u deploy rpm -ivh http://rpm.nguo.com/rpm/third_party/nguo-icinga-configs/nrpe/nguo-nagios-nrpe-config-1.0:base:136550-11_64el5.noarch.rpm
sudo -u deploy rpm -Uvh http://rpm.nguo.com/rpm/third_party/nguo-nagios/custom-plugins/nguo-nagios-custom-plugins-1.1-27_64el5.x86_64.rpm
"
	done
}

#
# Function to install RPM
install_rpm() {
	local RPM=$1
	shift
	local HOST=$@
	get_host_list
        for i in $HOST
        do
                echo "---- $i -----"
		ssh -o StrictHostkeyChecking=no $i sudo rpm -Uvh http://phx2-nasa-colo-master1.nguo.com/linux/admin/$RPM
		echo
	done
	
	exit 0
}

#
# Function to check if a given uid exists on given hosts.
check_uid() {
	local USER_ID=$1
	shift
	local HOST=$@
        get_host_list
        for i in $HOST
        do
		echo -ne "$i\t\t"
		ssh -o StrictHostkeyChecking=no $i id $USER_ID
	done
}

#
# Function to create the account on given hosts.
create_unix_account() {
	local USER_ID=$1
	shift
	local HOST=$@
        get_host_list
        for i in $HOST
        do
		echo -ne "$i\t\t"
		ssh -o StrictHostkeyChecking=no $i sudo /usr/local/bin/ruser $USER_ID
	done
}

#
# Generate ssl CSR 
generate_ssl_key_csr() {
	CN=$1
	cd ~/cert
	openssl genrsa -out ${CN}_XXXXXX.key 2048
	echo -ne "\n*********************************\n"
	openssl req -new -nodes -key ${CN}_XXXXXX.key -out ${CN}.csr
	echo -ne "\nThe CSR for $CN is located in ~/cert\n"
	exit 0
}


#
# Main
#
NO_ARGS=0
E_OPTERROR=10
E_HOSTERROR=20
E_INVOKERROR=30
COMMD=""
HSS=""

if [ "$#" -eq "$NO_ARGS" ]
then
	print_usage
	exit $E_OPTERROR
fi

#
# Get hostnames from STDIN
#while read HS
#do
#        H=`echo $HS| tr '\n' ' '`
#        HSS=$HSS$H
#done

#exec < /dev/tty
#
# Handling options
while getopts "a:c:f:g:H:i:r:u:sm" option
do
	case $option in 
	    i )		case $OPTARG in
			nrpe )	shift 2
				install_nrpe $HSS$@
				exit 0
				;;
			vmt  )  shift 2
				install_VMware_tools $HSS$@
				exit 0
				;;
			*    )  print_usage
				;;
			esac
			;; 	
	    u )		U=$OPTARG
			shift 2
			check_uid $U $HSS$@
			exit 0
			;;
	    a )         U=$OPTARG
                        shift 2
			create_unix_account $U $HSS$@
			exit 0
                        ;;
	    r )  	RPM=$OPTARG
			shift 2
			install_rpm $RPM $HSS$@
			;;			
	    m )		shift
			remount_var_opt $HSS$@
			;;
	    g )		cn=$OPTARG
			generate_ssl_key_csr $cn
			;;
	    f ) 	FN=$OPTARG
		#shift 2
			;;
	    c )		COMMD=$OPTARG
		#	shift 2
			;;
	    H )		get_host_list $OPTARG
	    		;;
	    s )		echo 'will be done'
	    		;;
	    * )		print_usage
	    		;;
	esac
done	


if [ -n "$COMMD" ];
then
#
# Hosts are given in a file.
  shift 2
  if [ ! -z ${FN+x} ]
  then
	if [ ! -f $FN ]
	then
		echo "File $FN doesn't exist!"
		exit 3
	fi

	shift 2

	for h in `cat $FN` $@
	do
		echo $h
		ssh -o connecttimeout=5 -o stricthostkeychecking=no $h $COMMD
	done
	exit 0
  fi

  if [ -n "$HSS" ]
  then
	for h in $HSS
	do
                echo $h
                ssh -o connecttimeout=5 -o stricthostkeychecking=no $h $COMMD
        done
  fi
else 
	# hosts are given in command line option
	shift 2
	CM=$@
	
	if [ ! -z ${FN+x} ]; then
		HOSTLIST=`cat $FN | xargs`
	else
		HOSTLIST=$HSS
	fi

	for h in $HOSTLIST	
	do
		$CM $h
		
	done
fi

exit 0
