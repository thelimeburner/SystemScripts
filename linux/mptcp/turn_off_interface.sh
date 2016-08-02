#!/bin/bash


##Need to install iproute2 after enabling multipath repos
## sudo apt install iproute2

sudo ./ip link set dev $1 multipath off
