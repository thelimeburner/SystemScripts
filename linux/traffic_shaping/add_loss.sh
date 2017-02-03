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
	echo "$0 Loss_$DEV1 Loss_$DEV2 <== Sets loss of each interface."
	echo "Example:"
	echo "$0 .1 .1 <== Sets both eno2 and eno3 to have .1% of a packet loss"
	echo "or"
	echo "$0 clear <== This resets loss"
	exit 0
fi

echo "Clearing Interfaces first"

#sudo tc qdisc del dev $DEV1 root
#sudo tc qdisc del dev $DEV2 root

echo "Setting $DEV1 to $1\%"
sudo tc qdisc change dev $DEV1 root netem loss $1%


echo "Setting $DEV2 to $2\%"

sudo tc qdisc change dev $DEV2 root netem loss $2%
