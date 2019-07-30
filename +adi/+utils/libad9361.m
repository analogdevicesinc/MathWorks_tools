classdef libad9361 < handle

    properties (Hidden)
        libad9361_win = 'https://github.com/analogdevicesinc/libad9361-iio/releases/download/v0.2/libad9361-0.2-win64.zip';
        libad9361_osx = 'https://github.com/analogdevicesinc/libad9361-iio/releases/download/v0.2/ad9361-0.2-Darwin.tar.gz';
        libad9361_linux= 'http://swdownloads.analog.com/cse/travis_builds/master_latest_libad9361-iio-trusty.tar.gz';
        os
        headerFileNames = {'ad9361.h','ad9361-wrapper.h'};
        libraryFileNames = {'ad9361','libad9361.so','libad9361.dll'};
        tmpdir = 'tmp_deps_install';
    end
    
    methods (Access=protected, Hidden)
        
        function loc = getDependencyTargetLocation(~)
            rootDir = fileparts(strtok(mfilename('fullpath'), '+'));
            loc = fullfile(rootDir,'deps','ad9361');
        end
        
        function [files,dlfn,fulltmp] = downloadFiles(obj)
            if ismac
                dlfn = websave('dl.tar.gz',obj.libad9361_osx);
                fulltmp = fullfile(pwd,obj.tmpdir);
                files = untar(dlfn,fulltmp);
            elseif ispc
                dlfn = websave('dl.zip',obj.libad9361_win);
                fulltmp = fullfile(pwd,obj.tmpdir);
                files = unzip(dlfn,fulltmp);
            else
                dlfn = websave('dl.tar.gz',obj.libad9361_linux);
                fulltmp = fullfile(pwd,obj.tmpdir);
                files = untar(dlfn,fulltmp);
            end
        end
        
    end
    
    methods     
        
        function [check,lib,head] = checkForDependencies(obj)
            loc = getDependencyTargetLocation(obj);
            lib = false;
            for l = 1:length(obj.libraryFileNames)
                lib = lib || exist(fullfile(loc,obj.libraryFileNames{l}),'file');
            end
            head = true;
            for h = 1:length(obj.headerFileNames)
                head = head && exist(fullfile(loc,'include',obj.headerFileNames{h}),'file');
            end
            check = lib && head;
        end
        
        function download_libad9361(obj)
            if obj.checkForDependencies()
                fprintf('Dependencies already installed, not reinstalling\n');
                return
            end
            fprintf('Downloading libad9361 library\n');
            [files,dlfn,fulltmp] = downloadFiles(obj);
            target = obj.getDependencyTargetLocation();
            if ~exist(target,'dir')
                mkdir(target);
            end
            if ~exist(fullfile(target,'include'),'dir')
                mkdir(fullfile(target,'include'));
            end
            % Includes
            for f = 1:length(files)
                if contains(files{f},obj.headerFileNames)
                    copyfile(files{f},fullfile(target,'include'));
                end
            end
            % Libraries
            for f = 1:length(files)
                if exist(files{f},'dir')
                    continue;
                end
                fp = split(files{f}, '/'); fp = fp{end};
                s = dir(files{f});
                if contains(fp,obj.libraryFileNames) && s.bytes>0
                    if ismac && ~contains(fp,'.')
                        copyfile(files{f},fullfile(target,'libad9361.dylib'));
                    end
                    if ispc && contains(files{f},'.dll')
                        copyfile(files{f},target);
                    end
                    if isunix
                        copyfile(files{f},fullfile(target,'libad9361.so'));
                    end
                end
            end
            % Cleanup
            rmdir(fulltmp,'s');
            delete(dlfn);            
            fprintf('Installing libad9361 complete\n');
            % Path stuff
            fprintf('Adding libad9361 to path\n');
            addpath(genpath(target));
            try
                warning('error','MATLAB:SavePath:PathNotSaved');
                savepath();
            catch
               warning(['savepath failed. libad9361 is currently on path, '...
                   'but is likely to not be across MATLAB restarts.',...
                   'Please add "',target,'" to path']);
            end
        end
    end
end



