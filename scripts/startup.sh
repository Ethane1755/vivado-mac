#!/bin/bash

# # if Vivado is installed
if [ -d "/home/user/Xilinx" ]
then
	/home/user/Xilinx/Vivado/*/bin/hw_server -e "set auto-open-servers xilinx-xvc:host.docker.internal:3721" &
	/home/user/Xilinx/Vivado/*/settings64.sh
	/home/user/Xilinx/Vivado/*/bin/vivado -nolog -nojournal
else
	echo "The installation is incomplete."
fi