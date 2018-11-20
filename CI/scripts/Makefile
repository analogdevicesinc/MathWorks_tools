# Usage:
#	make <MATLAB release version ex: R2018b> <HDL git branch ex: hdl_2018_r1>
# Example
#	make R2018b hdl_2018_r1

ifeq ($(MLRELEASE),)
MLRELEASE := R2018b
endif

ifeq ($(HDLBRANCH),)
HDLBRANCH := hdl_2018_r1
endif

GITTAG := $(shell git describe --tags HEAD)

.ONESHELL:
build:
	# Uses the HDLBRANCH variable
	bash build_bsp.sh

add_libad9361:
	cd ../..
	mkdir deps
	cd deps
	# Linux
	mkdir linux
	cd linux
	#curl --silent "https://api.github.com/repos/analogdevicesinc/libad9361-iio/releases/latest" | jq -r ".assets[] | select(.name | test(\"${spruce_type}\")) | .browser_download_url" | grep tar.gz | wget -i -
	wget http://swdownloads.analog.com/cse/travis_builds/master_latest_libad9361-iio-trusty.tar.gz
	tar xvf *.tar.gz
	mv usr/local/lib/* .
	mv usr/local/include ../
	rm -rf usr
	rm *.tar.gz
	cd ..
	# Windows
	mkdir win
	cd win
	wget "https://ci.appveyor.com/api/projects/analogdevicesinc/libad9361-iio/artifacts/libad9361-win64.zip?branch=master" -O lib.zip
	unzip lib.zip
	mv libad9361-win64/* .
	rm -rf libad9361-win64
	rm *.h
	rm lib.zip

test_installer:
	cd ../..
	cp *.mltbx test/
	cp hdl_wa_bsp/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m
	sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" test/hdlcoder_board_customization_local.m
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "cd('test');runInstallerTests;"

test:
	cd ../..
	cp hdl_wa_bsp/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m
	sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" test/hdlcoder_board_customization_local.m
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "cd('test');runTests;"

test_streaming:
	cd ../..
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "addpath(genpath('test'));addpath(genpath('deps'));hwTestRunner;"

test_modem:
	cd ../..
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "addpath(genpath('hdl_wa_bsp'));cd('targeting_models');addpath(genpath('modem-qpsk'))"

gen_tlbx:
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "genTlbx;exit();"

zip:
	cd ../..
	mkdir zip
	zip -r zip/AnalogDevicesBSP_$(GITTAG).zip deps doc hdl_wa_bsp hil_models targeting_models info.xml LICENSE README.md test/*.log

