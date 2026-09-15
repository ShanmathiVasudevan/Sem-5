#!/bin/bash
x=20
function bar(){
	y=$1
	#x=40 # if this is uncommented, output is 80
	echo $((x+y))
}
function foo(){
	x=30 # if this is commented out, output is 60
	echo $(bar 40)
}
echo $(foo) # output as the program is originally, is 70, as it is dynamically scoped.
