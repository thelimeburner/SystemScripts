#!/bin/bash

interfaces=("enp5s0f0" "enp5s0f1")

INTS="/sys/class/net/*"
for f in $INTS
do
	name=${f##*/}
    base=${name%.txt}
	#echo $base
	inarray=$(echo ${interfaces[@]} | grep -o "$base" | wc -w)

	if [ "$inarray" -eq "0" ]; then
		sudo ip link set dev $base multipath off
	fi
done
