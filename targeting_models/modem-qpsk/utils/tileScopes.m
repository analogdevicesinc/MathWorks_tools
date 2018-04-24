
function tileScopes(modelname)

% tileScopes(bdroot)

blocktypes = {'Constellation','Scope','Spectrum'};
%blocktypes = {'Scope','Spectrum'};

allscopes = {};
% Get all scopes
for block = blocktypes
    scopes = find_system(modelname,'CaseSensitive','off',...
        'regexp','on','LookUnderMasks','all',...
        'blocktype',block{:});
    allscopes = {allscopes{:},scopes{:}};
end
num = numel(allscopes);screenBorder = 0.1;
positions = getFigurePositions([ceil(sqrt(num)),ceil(sqrt(num))], screenBorder);

for s = 1:num
    open_system(allscopes{s});
    myConfiguration = get_param(allscopes{s},'ScopeConfiguration');
    myConfiguration.Position = positions(s,:);
    
end



end