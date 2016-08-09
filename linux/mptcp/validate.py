#!/usr/bin/python

#
# Reads the given file and checks if all values are as expected
#
#
#


import subprocess
from subprocess import Popen,PIPE
import sys
import os

###Define colors
ERROR = "\033[31m"  # Prints RED
PASS  = "\033[32m"  # Prints GREEN
RESET = "\033[0m"   # Resets Terminal
CYAN  = "\033[36m" # Prints Cyan

failed_keys = {}
fix_values = False
filename_index = 1
###Runs sysctl and returns the value
def check_value(key):
	output = subprocess.check_output("sysctl -n "+key, shell=True)
	return output.replace("\n","")

###Runs sysctl and returns the value
def set_value(key,value):
    cmd = "sudo sysctl -w "+key+"="+"\""+value+"\""
    p = Popen(cmd , shell=True, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    if(p.returncode != 0):
        print ERROR+err.rstrip()+RESET
    resultsLine = out.rstrip()
    return PASS+"SUCCESS"+RESET

## If a list is returned, this function is called to compare the values regardless of order
def validate_list(expected,actual,key):
	global failed_keys
	expected_list = expected.split(" ")
	actual_list = actual.split(" ")
	if set(expected_list) == set(actual_list):
		print key+": "+PASS+" Passed!"+RESET
	else:
		print key+": "+ERROR+" Failed!"+RESET
		print "\t Expected: "+expected
		print "\t Actual: "+ERROR+actual+RESET
		failed_keys[key] = expected




#iterates through failed keys, and trys to set the correct values
def fix():
	global failed_keys
	print "Attempting to fix value"
	for key in failed_keys:
		res = set_value(key,failed_keys[key])
		print "Attempted to Fix "+key+":"
		print "\t"+res

## Reads the given filename and returns a dict with the key being the sysctl key and the value being the expected
def read_file(filename):
	#file descriptor to operate on 
	f = open(filename,"r")
	# Dict for the vaues
	expected = {}
	for line in f:
		# Split along equals sign
		res = line.split("=")
		#Replace new line at end of line
		expected[res[0]] = res[1].replace("\n","")
	#Close the file
	f.close()
	#Return the dict
	return expected
	
#Prints message declaring whether it passed or failed
def printMsg(expected, actual,key):
	global failed_keys
	if expected == actual:
		print key+": "+PASS+" Passed!"+RESET
	else:
		print key+": "+ERROR+" Failed!"+RESET
		print "\t Expected: "+expected
		print "\t Actual: "+ERROR+actual+RESET
		failed_keys[key] = expected
# For every item in the expected dict, check the value.
def validate(expected):
	for key in expected:
		actual = check_value(key)
		if " " in expected[key]:
			validate_list(expected[key],actual,key)
		else: 
			printMsg(expected[key],actual,key)

if  len(sys.argv) > 3 or len(sys.argv) < 2:
	print CYAN+"Usage:\n\tpython "+sys.argv[0]+" VALIDATE_FILENAME"+RESET+" ==> Does not fix failed keys"
	print "\tor"
	print CYAN+"\tpython "+sys.argv[0]+" -f VALIDATE_FILENAME"+RESET+" ==> Fixes failed keys"
	exit(1)


if len(sys.argv) == 3 and sys.argv[1] != "-f":
	print CYAN+"Usage:\n\tpython "+sys.argv[0]+" VALIDATE_FILENAME"+RESET+" ==> Does not fix failed keys"
	print "\tor"
	print CYAN+"\tpython "+sys.argv[0]+" -f VALIDATE_FILENAME"+RESET+" ==> Fixes failed keys"
	exit(1)




if len(sys.argv) == 3 :
	fix_values = True
	filename_index = 2

filename = sys.argv[filename_index]
if not os.path.isfile(filename):
	print CYAN+"File "+filename+" does not exist!"+RESET
	exit(1)


#Extract config information from file
expected = read_file(filename)
validate(expected)
if fix_values and len(failed_keys) != 0:
	fix()
	validate(expected)
