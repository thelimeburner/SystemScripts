#!/bin/bash
#1 mptcp | tcp
#2 delay of path1
#3 delay of path2
#4 bw of path1
#5 bw of path2
#6 storage location
#7 queue size for router
#8 vmsize
#Configurables
#date=110116
host1=source1
host2=dest1
script="/workspace/SystemScripts/linux/mptcp"
#mptcp_file=mptcp_config
mptcp_file=mptcp_optimize
tcp_file=tcp_optimal
out_file=server_configuration
#storage=/results/$date/tcp/500/configs

#leave them be
filename=""
storage=$2
###Check correct # of args
if [ $# != 2 ]; then
        echo "Usage:"
        echo "$0 protocol storage_location"
        exit 0
fi

#check which configuration file to use
if [ "$1" == "mptcp" ]; then
        filename=$script"/$mptcp_file"
fi
if [ "$1" == "tcp" ]; then
        filename=$script"/$tcp_file"
fi





##Configures MPTCP or TCP options
set_protocol(){

    ssh $1 "$script/./validate.py -f $filename"


}


#Check for mptcp|tcp options
check_protocol(){
    echo "$1 MPTCP/TCP Options " >> $out_file
    ssh $1 "$script/./check_mptcp" >> $out_file
    echo "----------------------------" >> $out_file
}

# Check Window/BUffer Sizes
check_buffer(){
    echo "$1 Buffer Sizes">>$out_file
    ssh $1 "sysctl net.ipv4.tcp_rmem" >>$out_file
    ssh $1 "sysctl net.ipv4.tcp_wmem" >>$out_file
    ssh $1 "sysctl net.core.rmem_max" >>$out_file
    ssh $1 "sysctl net.core.wmem_max" >>$out_file
    echo "----------------------------" >> $out_file

}

## Flush routes?
flush_tcp_cache(){
    ssh $1 "sudo sysctl -w net.ipv4.route.flush=1"
    ssh $1 "sudo sysctl -w net.ipv4.tcp_no_metrics_save=1"
}



echo "" > $out_file

#clear_delay $router1
#clear_delay $router2

flush_tcp_cache $host1
flush_tcp_cache $host2


set_protocol $host1
set_protocol $host2

echo "Protocol Options" >> $out_file
check_protocol $host1
check_protocol $host2

echo "Window Buffer Options" >> $out_file
check_buffer $host1
check_buffer $host2

#sudo ./run_monitors.sh $path1_delay
