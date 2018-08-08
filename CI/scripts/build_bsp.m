%% Move to correct location
p = mfilename('fullpath');
p = strsplit(p,'/');
p = p(1:end-1);
p = strjoin(p,'/');
cd(p);
cd ..

%% Setup HDL repo
system('git clone --single-branch -b hdl_2018_r1 https://github.com/analogdevicesinc/hdl.git')
system('source /opt/Xilinx/Vivado/2017.4/settings64.sh');

%% Update adi_ip script to make sure archive are built in a portable way
copyfile('scripts/adi_ip.tcl', 'hdl/library/scripts/')

%% Pack all cores
system('/opt/Xilinx/Vivado/2017.4/bin/vivado -mode batch -source scripts/pack_all_ips.tcl && echo "success" || echo "failed"')

%% Repack i2s core to include xml files
cd hdl/library/axi_i2s_adi/
unzip('analog.com_user_axi_i2s_adi_1.0.zip','tmp')
delete('analog.com_user_axi_i2s_adi_1.0.zip')
copyfile('*.xml','tmp')
zip('analog.com_user_axi_i2s_adi_1.0.zip',{'*'},'tmp');
cd ../../..

cd hdl/library/util_i2c_mixer/
unzip('analog.com_user_util_i2c_mixer_1.0.zip','tmp')
delete('analog.com_user_util_i2c_mixer_1.0.zip')
copyfile('*.xml','tmp')
zip('analog.com_user_util_i2c_mixer_1.0.zip',{'*'},'tmp');
cd ../../..

%% Move all cores
system('/opt/Xilinx/Vivado/2017.4/bin/vivado -mode batch -source scripts/copy_all_packed_ips.tcl && echo "success" || echo "failed"')
!cp -r hdl/library/jesd204/*.zip hdl/library/
!cp -r hdl/library/xilinx/*.zip hdl/library/
!rm -rf hdl/projects
!cp -r projects hdl/

%% Remove unused projects in BSP
% cd hdl/projects
% whitelist = {'..','.','scripts','fmcomms5','fmcomms2','common','adrv9361z7035','adrv9364z7020','adrv9009'};
% files = dir('.');
% files = {files.name};
% for file = files
%     if ~ismember(file{:},whitelist)
%         disp(file{:})
%         if isfile(file{:})
%             delete(file{:});
%         elseif isfolder(file{:})
%             rmdir(file{:},'s');
%         end
%     end
% end
% cd ../..

%% Update tcl scripts and additional IP cores (MUX)
copyfile('scripts/adi_project.tcl', 'hdl/projects/scripts/')
copyfile('scripts/adi_build.tcl', 'hdl/projects/scripts/')
copyfile('ip/*.zip', 'hdl/library/')
movefile('hdl','../../hdl_wa_bsp/vendor/AnalogDevices/vivado')

%% Cleanup
delete('vivado_*')
delete('vivado.jou')
delete('vivado.log')

