function install(mode)
% hdlbsp.install adds/removes common BSP utilities

% Copyright 2016 MathWorks, Inc. All Rights Reserved.

    if nargin == 0
        mode = 0;
    end

    %% Initialization
    % Determine where we're operating out of
    hdlbspRootDir = fileparts(strtok(mfilename('fullpath'), '+'));
    olddir = cd(hdlbspRootDir); % Make sure we can access the tools
    cleanup = onCleanup(@()cd(olddir));

    % Update the path
    paths = {...
        fullfile(hdlbspRootDir),...    
    };

    hdlbsp.util.vendorInstall(mode,paths);
end