#!/bin/bash

num=$1
mode=fullmesh
#mode=ndiffports

sudo sh -c "echo $num > /sys/module/mptcp_${mode}/parameters/num_subflows"
