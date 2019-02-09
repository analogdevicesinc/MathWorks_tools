v = adi.Version;

cd('hdl_wa_bsp/vendor/AnalogDevices');
fileID = fopen('Contents.m','w');
fprintf(fileID,'%% HDL Coder BSP: Analog Devices Inc\n');
fprintf(fileID,'%% Version %s (%s) %s\n',v.Release,v.MATLAB,date);
fclose(fileID);
cd('../../..')

cd('+adi');
fidw = fopen('Contents.txt','w');
fprintf(fidw,'%% Analog Devices Inc. Board Support Packages\n');
fprintf(fidw,'%% Version %s (%s) %s\n',v.Release,v.MATLAB,date);
fidr = fopen('Contents.m','r');
fgetl(fidr);
fgetl(fidr);
l = fgetl(fidr);
while ~isempty(l)
    disp(l);
    fprintf(fidw,['%',l,'\n']);
    l = fgetl(fidr);
end
fclose(fidw);
fclose(fidr);
movefile('Contents.txt','Contents.m');
cd('..');
