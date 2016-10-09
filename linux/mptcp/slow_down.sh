#!/bin/bash


# $1 is the bandwdith for  interface1
# $2 is the bandwidth for interface2
# $3 is the delay for interface1
# $4 is the delay for interface2


DEV1=eno2
DEV2=eno3
# Delete Existing tree
sudo tc qdisc del dev $DEV1 root


# Add parent
sudo tc qdisc add dev $DEV1 root handle 1: cbq avpkt 1000 bandwidth 1000mbit


# Add class
sudo tc class add dev $DEV1 parent 1: classid 1:1 cbq rate $1mbit \
          allot 1500 prio 5 bounded isolated

# add delay
sudo tc qdisc add dev $DEV1 parent 1:1  netem delay $3ms


# Apply filters
sudo tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
          match ip dst 0.0.0.0/0 flowid 1:1

# Apply filters
sudo tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
          match ip src 172.0.0.10 flowid 1:1

# Delete Existing tree
sudo tc qdisc del dev $DEV2 root


# Add parent
sudo tc qdisc add dev $DEV2 root handle 1: cbq avpkt 1000 bandwidth 1000mbit


# Add class
sudo tc class add dev $DEV2 parent 1: classid 1:1 cbq rate $2mbit \
          allot 1500 prio 5 bounded isolated

# add delay
sudo tc qdisc add dev $DEV2 parent 1:1  netem delay $4ms


# Apply filters
sudo tc filter add dev $DEV2 parent 1: protocol ip prio 16 u32 \
          match ip dst 0.0.0.0/0 flowid 1:1

# Apply filters
sudo tc filter add dev $DEV2 parent 1: protocol ip prio 16 u32 \
          match ip src 192.168.1.10 flowid 1:1

