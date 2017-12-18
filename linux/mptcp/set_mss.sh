#!/bin/bash

#IFACES="eno1 eno2 eno4"
IFACES="eno2 eno4"
#IFACES="enp5s0f0 enp5s0f1"
TXQ=$2
MTU=$1



# Let's use jumbo frames
for iface in $IFACES; do
	sudo ifconfig $iface mtu $MTU txqueuelen $TXQ
done
