#!/bin/bash
DEV1=eno2
DEV2=eno3
if [ "$1" == "clear" ]; then
    sudo tc qdisc del dev $DEV1 root
    sudo tc qdisc del dev $DEV2 root
    echo "Cleared interfaces"
    exit 0
fi

if [ $# -eq 0 ]; then
	echo "Not enough arguments";
	echo "Usage:" 
	echo "$0 Bandwdith_for_$DEV1 Bandwidth_for_$DEV2 <== Sets bandwdith of each interface. Uses megabits for units"
	echo "Example:"
	echo "$0 500 500 <== Sets both eno2 and eno3 to have 500megabit bandwidth"
	echo "or"
	echo "$0 clear <== This resets bandwdith"
	exit 0
fi

echo "Clearing Interfaces first"

sudo tc qdisc del dev $DEV1 root
sudo tc qdisc del dev $DEV2 root

echo "Setting $DEV1 to $1mbit"
tc qdisc add dev $DEV1 root handle 1: cbq avpkt 1000 bandwidth 1000mbit 

tc class add dev $DEV1 parent 1: classid 1:1 cbq rate $1mbit \
	  allot 1500 prio 5 bounded isolated 

tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
	  match ip dst 0.0.0.0/0 flowid 1:1

tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
	  match ip src 172.0.0.10 flowid 1:1


echo "Setting $DEV2 to $1mbit"
tc qdisc add dev $DEV2 root handle 1: cbq avpkt 1000 bandwidth 1000mbit 

tc class add dev $DEV2 parent 1: classid 1:1 cbq rate $2mbit \
	  allot 1500 prio 5 bounded isolated 

tc filter add dev $DEV2 parent 1: protocol ip prio 16 u32 \
	  match ip dst 0.0.0.0/0 flowid 1:1

tc filter add dev $DEV2 parent 1: protocol ip prio 16 u32 \
	  match ip src 192.168.1.10 flowid 1:1
