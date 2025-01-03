#!/bin/bash

# # if Vivado is installed
if [ -d "/home/user/Xilinx" ]
then
	/home/user/Xilinx/Vivado/*/settings64.sh
	/home/user/Xilinx/Vivado/*/bin/vivado -nolog -nojournal
else
	echo "The installation is incomplete."
fi