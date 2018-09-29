#!/bin/bash

HDLBRANCH='hdl_2018_r1'

# Script is designed to run from specific location
scriptdir=`dirname "$BASH_SOURCE"`
cd $scriptdir
cd ..

# Get HDL
git clone --single-branch -b $HDLBRANCH https://github.com/analogdevicesinc/hdl.git

# Get required vivado version needed for HDL
VER=$(awk '/set REQUIRED_VIVADO_VERSION/ {print $3}' hdl/library/scripts/adi_ip.tcl | sed 's/"//g')
echo "Required Vivado version ${VER}"
if [ ${#VER} = 8 ]
then
VER=${VER:0:6}
fi
VIVADO=${VER}

# Setup
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh

cp scripts/adi_ip.tcl hdl/library/scripts/

# Pack IP cores
vivado -mode batch -source scripts/pack_all_ips.tcl

# Repack i2s and i2c cores to include xml files
cd hdl/library/axi_i2s_adi/
unzip analog.com_user_axi_i2s_adi_1.0.zip -d tmp
rm analog.com_user_axi_i2s_adi_1.0.zip
cp *.xml tmp/
cd tmp
zip -r analog.com_user_axi_i2s_adi_1.0.zip *
cp analog.com_user_axi_i2s_adi_1.0.zip ../
cd ../../../..

cd hdl/library/util_i2c_mixer/
unzip analog.com_user_util_i2c_mixer_1.0.zip -d tmp/
rm analog.com_user_util_i2c_mixer_1.0.zip
cp *.xml tmp/
cd tmp
zip -r analog.com_user_util_i2c_mixer_1.0.zip *
cp analog.com_user_util_i2c_mixer_1.0.zip ../
cd ../../../..

# Move all cores
vivado -mode batch -source scripts/copy_all_packed_ips.tcl

cp -r hdl/library/jesd204/*.zip hdl/library/
cp -r hdl/library/xilinx/*.zip hdl/library/
rm -rf hdl/projects
cp -r projects hdl/

# Update tcl scripts and additional IP cores (MUX)
cp scripts/adi_project.tcl hdl/projects/scripts/
cp scripts/adi_build.tcl hdl/projects/scripts/
cp ip/*.zip hdl/library/
rm -fr hdl/.git
cp -r hdl ../hdl_wa_bsp/vendor/AnalogDevices/vivado

# Cleanup
rm vivado_*
rm vivado.jou
rm vivado.log
rm -rf hdl

