function [rxMsg, SQ] = ModeS_DataSearch4(data, thr, SQ)
%% ModeS_DataSearch1.m looks for values within data that exceed a threshold
% above the noise floor. It then processes the possible ModeS message
% and returns valid messages to rxMsg.

% Copyright 2010-2011, The MathWorks, Inc.

m = mean(data);
recCount = 0;
rxMsg = '8D00000000000000000000000000';

% fileIndex = find(data>thr*m,1,'first');

fileIdx = find(data>thr*m);
if ~isempty(fileIdx)
    nextIdx = 0;
    for ii = 1:numel(fileIdx);
        if (fileIdx(ii)>nextIdx)
            fileIndex = fileIdx(ii);
            if (fileIndex > 100 && fileIndex < length(data)-1900)
                [rx, SQ] = ModeS_ReadMsg4(data(fileIndex-100:fileIndex+1899),SQ);
            else
                rx = '8d00000000000000000000000000';
            end
            if (strcmp(rx,'8d00000000000000000000000000')==0)
                recCount = recCount+1;
                rxMsg(recCount,:) = rx;
            end
            nextIdx = fileIdx(ii)+1899;
        end
    end
end