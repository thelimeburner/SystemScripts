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
	echo "$0 Latency_$DEV1 Latency_$DEV2 <== Sets latency of each interface. Uses ms for units"
	echo "Example:"
	echo "$0 500 500 <== Sets both eno2 and eno3 to have 500ms latency"
	echo "or"
	echo "$0 clear <== This resets bandwdith"
	exit 0
fi

echo "Clearing Interfaces first"

#sudo tc qdisc del dev $DEV1 root
#sudo tc qdisc del dev $DEV2 root

echo "Setting $DEV1 to $1ms"
sudo tc qdisc add dev $DEV1 root netem delay $1 10ms 25%


echo "Setting $DEV2 to $2ms"

sudo tc qdisc add dev $DEV2 root netem delay $2 10ms 25%
