
version = '18.2';

%%
cd(fileparts((mfilename('fullpath'))));
cd('../..');
p = pwd;
cd(fileparts((mfilename('fullpath'))));

fid  = fopen('bsp.tmpl','r');
f=fread(fid,'*char')';
fclose(fid);

f = strrep(f,'__REPO-ROOT__',p);
f = strrep(f,'__VERSION__',version);

fid  = fopen('../../bsp.prj','w');
fprintf(fid,'%s',f);
fclose(fid);

cd('../..');
pwd
rmpath(genpath('.'));
ps = {'doc','hdl_wa_bsp','hil_models','targeting_models'};
paths = '';
for p = ps
    pp = genpath(p{:});
    ppF = pp;
    pp = pp(1:end-1);
    pp = strrep(pp,':','</matlabPath><matlabPath>');
    paths = [paths,['<matlabPath>',pp,'</matlabPath>']]; %#ok<AGROW>
    addpath(ppF);
end
rehash
projectFile = 'bsp.prj';
currentVersion = matlab.addons.toolbox.toolboxVersion(projectFile);
outputFile = ['AnalogDevicesBSP_v',currentVersion];
matlab.addons.toolbox.packageToolbox(projectFile,outputFile)

if ~usejava('desktop')
%% Update toolbox paths
mkdir other
movefile([outputFile,'.mltbx'], ['other/',outputFile,'.zip']);
cd other
unzip([outputFile,'.zip'],'out');
cd('out')
cd('metadata');
fid  = fopen('configuration.xml','r');
f=fread(fid,'*char')';
fclose(fid);

s = '</matlabPaths>';
sections = strsplit(f,s);
s1 = sections{1};
s2 = sections{2};
newfile = [s1,paths,s,s2];

fid  = fopen('configuration.xml','w');
fprintf(fid,'%s',newfile);
fclose(fid);

%% Repack
cd('..');
zip([outputFile,'.zip'], '*');
movefile([outputFile,'.zip'],['../../',outputFile,'.mltbx']);
cd('../..');
rmdir('other','s');
end

delete bsp.prj



