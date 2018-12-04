clc;
ignoreFolders = {'CI','doc','test'};
cd ../..
d = pwd;
cd ..
addpath(genpath(d));
cd(d);

files = dir('**/*.m');
for file = 1:length(files)
    if contains(files(file).folder,ignoreFolders)
        continue;
    end
    mfile = fullfile(files(file).folder,files(file).name);
    rpt = mlint(mfile);
    if ~isempty(rpt)
         disp(mfile);
         for l = 1:length(rpt)
             disp([num2str(rpt(l).line) ': ' rpt(l).message]);
         end
    end
end

