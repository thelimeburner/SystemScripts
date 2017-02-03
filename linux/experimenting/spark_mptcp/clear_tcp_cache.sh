#!/bin/bash

sudo sysctl -w net.ipv4.route.flush=1
sudo sysctl -w net.ipv4.tcp_no_metrics_save=1
