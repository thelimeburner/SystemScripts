#!/bin/bash
#buffer_size=$(expr $1 * 1e-6)
buffer_size=$(echo "${1}/.000001" | bc)



sudo sysctl -w net.ipv4.tcp_rmem="10240 87380 $buffer_size"
sudo sysctl -w net.ipv4.tcp_wmem="10240 87380 $buffer_size"
sudo sysctl -w net.core.rmem_max=$buffer_size
sudo sysctl -w net.core.wmem_max=$buffer_size


sudo sysctl -w net.ipv4.tcp_no_metrics_save=1
sudo sysctl -w net.ipv4.route.flush=1
#sysctl net.ipv4.tcp_rmem
#sysctl net.ipv4.tcp_wmem
#sysctl net.core.rmem_max
#sysctl net.core.wmem_max


