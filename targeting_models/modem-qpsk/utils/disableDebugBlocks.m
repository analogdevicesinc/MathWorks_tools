function toggleDebugBlocks(modelname,turnOn)

blocktypes = {'DEBUG'};
%blocktypes = {'Scope','Spectrum'};

allscopes = {};
% Get all scopes
for block = blocktypes
    scopes = find_system(modelname,'CaseSensitive','off',...
        'regexp','on','LookUnderMasks','all',...
        'Name',block{:});
    allscopes = {allscopes{:},scopes{:}};
end

disp(allscopes);