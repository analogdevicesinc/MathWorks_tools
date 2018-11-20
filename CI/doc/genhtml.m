[filepath,name,ext] = fileparts(mfilename('fullpath'));
cd(filepath);
files = dir(filepath);

target = '../../doc/';

skip = {'NA'};

for f = {files.name}
    if strfind(f{:},'.mlx')>=0
        filename = f{:};
        if contains(filename,skip)
            continue;
        end
        htmlFilename = [filename(1:end-4),'.html'];
        disp(htmlFilename);
        matlab.internal.liveeditor.openAndConvert(filename,htmlFilename);
        movefile(htmlFilename,target);
    end
end
