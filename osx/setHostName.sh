#!/bin/bash

##This script sets the hostname of a mac machine
## $1 is the hostname to set to



sudo scutil --set ComputerName "$1"
sudo scutil --set LocalHostName "$1"
sudo scutil --set HostName "$1"
