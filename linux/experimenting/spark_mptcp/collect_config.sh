#!/bin/bash

#
# This script reads the slaves file in your $SPARK_HOME config directory and runs commands on slaves to gather information about how they are configured. 
# Make sure $SPARK_HOME is exported to allow for the discovery of the slaves file
#
#

if [ $# -eq 0 ]; then
    echo "Usage: ./collect_config.sh PLACE_TO_PUT_CONFIGURATION"
    exit 1
fi




#Store argument as file locatioin
file_location=$1
#check if trailing slash omitted. If so add slash
if [ "${file_location: -1}" != "/" ]
then
	file_location+="/"
fi


##Runs ssh command and prints the results to the file
## $1 = host to run on
## $2 = command to run
## $3 = location to store it on
run_ssh(){

	ssh -n $1 $2 >> $3
	echo "---" >> $3
	echo "" >> $3
}

#Function to collect networking data
#$1 is the host we are interested in
collect_networking(){
		#Make directory to store data
		mkdir  -p $file_location"networking"

		#store location of diretory
		net_dest=$file_location"networking/$1"

		echo "$1:" >> $net_dest
		echo "MPTCP Configuration  ">> $net_dest
		run_ssh $1 "sysctl -a | grep mptcp" $net_dest
		echo "TCP Configuration  ">> $net_dest
		run_ssh $1 "sysctl -a | grep tcp" $net_dest


}

#Function to collect system information
# $1 is the host we are interested int
collect_system(){
	#Make directory to store data
	mkdir -p $file_location"system"
	
	#store location of directory
	dest=$file_location"system/$1"
	echo "$1:" >> $dest
	echo "Kernel Version ">> $dest
	run_ssh $1 "cat /proc/version" $dest
}

##Generic function that allows you to collect specified information
# $1 is the host we care about
# $2 is the title to use for the entry
# $3 is the folder to store data
# $4 is the command to run
collect_info(){
	#Make directory to store data
	mkdir -p $file_location$3

	dest=$file_location$3"/"$1
	#echo "$1:" >> $dest
	echo $2 >> $dest
	ssh -n $1 $4 >> $dest
	echo "---" >> $dest
	echo "" >> $dest

#
}

# Read through slaves file
while read p; do
	if [[ $p != *"#"* ]] && [ "$p" != "" ]
	then
		echo "Collecting information for:" $p
		#collect_networking $p
		collect_info $p "MPTCP Configuration" "networking" "sysctl -a | grep mptcp"
		collect_info $p "TCP Configuration" "networking" "sysctl -a | grep tcp"
		collect_info $p "Kernel Version" "system" "cat /proc/version"
		collect_info $p "OS RELEASE" "system" "cat /etc/*release* "
		collect_info $p "Block Devices" "system" "lsblk"
		collect_info $p "CPUS " "system" " cat /proc/cpuinfo"
		collect_info $p "Memory " "system" "cat /proc/meminfo"
		collect_info $p "Memory Max" "system" "lshw -short -C memory"
		collect_info $p "Networking" "networking" "lshw -class network"
		collect_info $p "MPTCP Rules" "networking" "ip rule show"
		collect_info $p "MPTCP Routes" "networking" "ip route"
		collect_info $p "MPTCP Route 1" "networking" "ip route show table 1"
		collect_info $p "MPTCP Route 2" "networking" "ip route show table 2"
		collect_info $p "Hardware" "hardware" "lshw "
	fi

done < $SPARK_HOME/conf/slaves

