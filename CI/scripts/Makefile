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

test_installer:
	cd ../..
	git clone --branch installer-tests https://github.com/analogdevicesinc/MathWorks_tools.git itests
	cp hdl_wa_bsp/vendor/AnalogDevices/hdlcoder_board_customization.m itests/test/hdlcoder_board_customization_local.m
	sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" itests/test/hdlcoder_board_customization_local.m
	cp *.mltbx itests/test/
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "rmpath(genpath('.'));cd('itests/test');runTests;bdclose('all');exit(any([results.Failed]));"

test:
	cd ../..
	cp hdl_wa_bsp/vendor/AnalogDevices/hdlcoder_board_customization.m test/hdlcoder_board_customization_local.m
	sed -i "s/hdlcoder_board_customization/hdlcoder_board_customization_local/g" test/hdlcoder_board_customization_local.m
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "cd('test');runTests;bdclose('all');exit(any([results.Failed]));"

gen_tlbx:
	cd ../..
	/usr/local/MATLAB/$(MLRELEASE)/bin/matlab -nodisplay -r "addpath(genpath('.'));cd('CI/scripts');genTlbx;"

zip:
	cd ../..
	zip -r AnalogDevicesBSP_$(GITTAG).zip doc hdl_wa_bsp hil_models targeting_models info.xml LICENSE README.md test/*.log

