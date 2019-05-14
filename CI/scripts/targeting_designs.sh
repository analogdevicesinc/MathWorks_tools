#!/bin/bash

MLFLAGS="-nodisplay -nodesktop -nosplash"

if [ -z "$MLRELEASE" ]
then
	MLRELEASE=R2018b
fi

MLPATH=/usr/local/MATLAB

cd ../.. 
source /opt/Xilinx/Vivado/2017.4/settings64.sh
Xvfb :77 &
export DISPLAY=:77
export SWT_GTK3=0
source /opt/Xilinx/Vivado/2017.4/settings64.sh
$MLPATH/$MLRELEASE/bin/matlab $MLFLAGS -r "addpath(genpath('test'));addpath(genpath('deps'));runDemoTests;"
kill -9 `pidof Xvfb`
