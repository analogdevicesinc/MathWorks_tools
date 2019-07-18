#!/bin/bash
if [ -z "${HDLBRANCH}" ]; then
HDLBRANCH='hdl_2018_r2'
fi


# Script is designed to run from specific location
scriptdir=`dirname "$BASH_SOURCE"`
cd $scriptdir
cd ..

# Get HDL
if [ -d "hdl" ]; then
    rm -rf "hdl"
fi
if ! git clone --single-branch -b $HDLBRANCH https://github.com/analogdevicesinc/hdl.git
then
   exit 1
fi

# Get required vivado version needed for HDL
VER=$(awk '/set REQUIRED_VIVADO_VERSION/ {print $3}' hdl/library/scripts/adi_ip.tcl | sed 's/"//g')
echo "Required Vivado version ${VER}"
VIVADOFULL=${VER}
if [ ${#VER} = 8 ]
then
VER=${VER:0:6}
fi
VIVADO=${VER}

# Setup
source /opt/Xilinx/Vivado/$VIVADO/settings64.sh

# Update build scripts and force vivado versions
cp scripts/adi_ip.tcl hdl/library/scripts/
VERTMP=$(awk '/set REQUIRED_VIVADO_VERSION/ {print $3}' hdl/library/scripts/adi_ip.tcl | sed 's/"//g')
grep -rl ${VERTMP} hdl/library/scripts | xargs sed -i -e "s/${VERTMP}/${VIVADOFULL}/g"

# Update relative paths
FILES=$(grep -lrnw hdl/projects -e "\.\.\/common" | grep -v Makefile)
for f in $FILES
do
  echo "Updating relative paths of: $f"
  DEVICE=$(echo "$f"| cut -d "/" -f 3)
  STR="\$ad_hdl_dir\/projects\/$DEVICE"
  sed -i "s/\.\.\/common/$STR\/common/g" "$f"
done

# Rename .prj files since MATLAB ignores then during packaging
FILES=$(grep -lrn hdl/projects/common -e '.prj' | grep -v Makefile | grep -v .git)
for f in $FILES
do
  echo "Updating prj reference in: $f"
  sed -i "s/\.prj/\.mk/g" "$f"
done
FILES=$(find hdl/projects/common -name "*.prj")
for f in $FILES
do
  DEST="${f::-3}mk"
  echo "Renaming: $f to $DEST"
  mv "$f" "$DEST"
done



# Pack IP cores
echo "Starting IP core packaging"
vivado -mode batch -source scripts/pack_all_ips.tcl > /dev/null 2>&1

# Repack i2s and i2c cores to include xml files
cd hdl/library/axi_i2s_adi/
unzip analog.com_user_axi_i2s_adi_1.0.zip -d tmp
rm analog.com_user_axi_i2s_adi_1.0.zip
ls
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
echo "Moving all cores"
vivado -mode batch -source scripts/copy_all_packed_ips.tcl > /dev/null 2>&1

cp -r hdl/library/jesd204/*.zip hdl/library/
cp -r hdl/library/xilinx/*.zip hdl/library/
cp -r hdl/projects/common common
cp -r hdl/projects/scripts/adi_board.tcl .

mv hdl/projects projects_premerge
cp -r projects hdl/
cp -R projects_premerge/* hdl/projects/
rm -rf projects_premerge

cp -R common/* hdl/projects/common/
rm -rf common
mv adi_board.tcl hdl/projects/scripts/

# Update tcl scripts and additional IP cores (MUX)
cp scripts/adi_project.tcl hdl/projects/scripts/
cp scripts/adi_build.tcl hdl/projects/scripts/
cp ip/*.zip hdl/library/

# Update vivado version in MATLAB API and build script
DEFAULT_V_VERSION='2017.4'
cd ..
echo "SED 1"
grep -rl ${DEFAULT_V_VERSION} hdl_wa_bsp/vendor/AnalogDevices/+AnalogDevices | grep -v MODEM | xargs sed -i "s/${DEFAULT_V_VERSION}/$VIVADO/g"
cd CI
echo "SED 2"
grep -rl ${DEFAULT_V_VERSION} hdl/projects/scripts | xargs sed -i "s/${DEFAULT_V_VERSION}/$VIVADOFULL/g"

# Remove git directory move to bsp folder
rm -fr hdl/.git*
TARGET="../hdl_wa_bsp/vendor/AnalogDevices/vivado"
if [ -d "$TARGET" ]; then
    rm -rf "$TARGET"
fi
cp -r hdl $TARGET

# Cleanup
rm vivado_*
rm vivado.jou
rm vivado.log
rm -rf hdl
