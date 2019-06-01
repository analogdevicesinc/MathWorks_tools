#!/bin/bash

# Build kernel
git clone https://github.com/analogdevicesinc/linux.git
cd linux
git checkout 2018_R2
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
source /opt/Xilinx/Vivado/2018.2/settings64.sh
cp ../hopper.patch .
git apply hopper.patch
make zynq_xcomm_adv7511_defconfig
make -j4 UIMAGE_LOADADDR=0x8000 uImage
