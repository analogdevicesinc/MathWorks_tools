#!/bin/bash
# This file is run inside of the docker container
echo "Copying HSP files"
cp -r /mlhspro /mlhsp
echo "Copying .matlab"
cp -r /root/.matlabro /root/.matlab
echo "Copying .Xilinx"
cp -r /root/.Xilinxro /root/.Xilinx
