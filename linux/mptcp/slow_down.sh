#!/bin/bash

DEV1=eno2

# Delete Existing tree
sudo tc qdisc del dev eno2 root


# Add parent
sudo tc qdisc add dev $DEV1 root handle 1: cbq avpkt 1000 bandwidth 1000mbit


# Add class
sudo tc class add dev $DEV1 parent 1: classid 1:1 cbq rate 500mbit \
          allot 1500 prio 5 bounded isolated

# add delay
sudo tc qdisc add dev eno2 parent 1:1  netem delay 100ms


# Apply filters
sudo tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
          match ip dst 0.0.0.0/0 flowid 1:1

# Apply filters
sudo tc filter add dev $DEV1 parent 1: protocol ip prio 16 u32 \
          match ip src 172.0.0.10 flowid 1:1

