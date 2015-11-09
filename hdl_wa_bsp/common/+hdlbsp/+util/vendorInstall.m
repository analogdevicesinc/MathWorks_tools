function vendorInstall(mode, dirs)
% hdlbsp.util.vendorInstall adds/removes vendor BSPs

% Copyright 2015 MathWorks, Inc. All Rights Reserved.


    %% Initialization
    if mode == 0
        pathfunc = @addpath;
    else
        pathfunc = @rmpath;
    end
    
    
    % Determine the currently running version
    mlRel = version('-release');
    mlRelNum = decodeRel(mlRel);
    
    % For each path to be added
    for ii = 1:numel(dirs)
        % add or remove the path
        pathfunc(dirs{ii});
        
        if (mode == 0)
            % If we're adding a path, check for a Contents.m file
            verInfo = ver(dirs{ii});
            if ~isempty(verInfo)
                % Contents.m found, compare the versions
                bspRel = regexprep(verInfo.Release, 'R|\(|\)', '');
                bspRelNum = decodeRel(bspRel);
                
                if mlRelNum > bspRelNum
                    % Target release is older-- warn about it
                    warning('%s is designed for R%s, but you are installing on R%s',...
                        verInfo.Name,bspRel,mlRel);
                elseif mlRelNum < bspRelNum
                    % Target release is newer-- error out
                    error('%s is designed for R%s, but you are installing on R%s',...
                        verInfo.Name,bspRel,mlRel);
                end
            end
        end
    end
    
    % Save the path
    status = savepath;
    if status
        error('Failed to save the path!');
    end

    %% Cleanup
    rehash('toolboxreset');
    rehash('toolboxcache');
    updateHdlwaPlatformList('ip_core');
end

function relNum = decodeRel(relStr)
    % Convert release string to a decimal number
    % R2015a --> 2015.0
    % R2015b --> 2015.1
    relInfo = regexp(relStr,'R?(?<year>\d+)(?<rel>a|b)', 'names');
    relNum = str2double(relInfo.year);
    if isequal(relInfo.rel, 'b')
        relNum = relNum + 0.1;
    end
end