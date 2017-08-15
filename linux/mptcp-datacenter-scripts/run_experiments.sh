#!/bin/bash

TCPDUMP_CORES=0
WRKLOAD_CORE="1-31"
NAME=$1
workload=$2
dst1=10.16.0.91
dst2=172.16.0.91
src1=10.16.0.90
src2=172.16.0.90
script_output=$NAME

##### HELPER FUNCTIONS.

run_monitors(){

	mkdir -p $script_output
	
	tools/./collect_config.sh $script_output

	flush_tcp_cache



	#sudo tcpdump -s 128 -w $NAME.pcap -i any -n "net 10.16.0.0/24 or net 172.16.0.0/24 and tcp" &
	#sudo tcpdump -s 0 -w $NAME.pcap -i any net 10.16.0.0/24 and 172.16.0.0/24 tcp
	#sudo tcpdump -s 128 -i any -n "(dst 10.16.0.91 and src 10.16.0.90) or (dst 10.16.0.91 and src 172.16.0.90) or (dst 172.16.0.91 and src 10.16.0.90) or (dst 172.16.0.91 and src 172.16.0.90) or (dst 172.16.0.90 and src 172.16.0.91) or (dst 172.16.0.90 and src 10.16.0.91) or (dst 10.16.0.90 and src 172.16.0.91) or (dst 10.16.0.90 and src 10.16.0.91) and tcp"
	sudo tcpdump -s 128 -w $script_output/$NAME.pcap -i any -n "(dst $dst1 and src $src1) or (dst $dst1 and src $src2) or (dst $dst2 and src $src1) or (dst $dst2 and src $src2) or (dst $src2 and src $dst2) or (dst $src2 and src $dst1) or (dst $src1 and src $dst2) or (dst $src1 and src $dst1) and tcp" &>/dev/null &   
	dump_pid=$!
	sudo taskset -cp $TCPDUMP_CORES $dump_pid
	taskset -cp $dump_pid

	sudo ifstat -bnt > $script_output/${NAME}_ifstat.out &
	ifstat_pid=$!


	sudo vmstat -tn 5 > $script_output/${NAME}_vmstat.out &
	vmstat_pid=$!

	sudo /scripts/tools/./ss_monitor.sh 5 > $script_output/${NAME}_ss.out &
	ss_pid=$!



}

run_iperf(){
	### SSH to destination to start iperf
	ssh $dst1 screen -d -m iperf -s
	run_monitors 
	echo "PIDS:"
	echo "TCPDUMP: $dump_pid"
	echo "Ifstat: $ifstat_pid"
	echo "vmstat: $vmstat_pid"
	echo "ss: $ss_pid"
	echo "Running Iperf"
	iperf -c $dst1 -n 100000M > $script_output/${NAME}_iperf.out 
	echo "Finished Run!"
	sudo kill -15 $dump_pid
	sudo kill -15 $ifstat_pid
	sudo kill -15 $vmstat_pid
	sudo kill -15 $ss_pid


	ssh $dst1 pkill -9 iperf
	echo "Experiment Complete. Ouput located: $script_output/${NAME}_iperf.out"
	exit
}


##### END HELPER FUNCTIONS



if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters"
    echo "$0 output_name worklaod"
    echo "EX: $0 sample1 rsync"
    echo "Available workloads: iperf rsync"
    exit
fi

if [ "$workload" == "iperf" ]; then
	echo "Running Iperf workload!"
	run_iperf 
	workload="iperf"
	exit
elif [ "$workload" == "rsync" ]; then
	echo "Not implemented yet!"
	exit
else
    echo "Illegal number of parameters"
    echo "$0 output_name worklaod"
    echo "EX: $0 sample1 rsync"
    echo "Available workloads: iperf rsync"
    exit
fi









