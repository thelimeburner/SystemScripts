#!/bin/bash

START=$SECONDS


 while true 
 do
     date +%H:%M:%S
     ss -ti
     echo "---"
     sleep $1
 done
