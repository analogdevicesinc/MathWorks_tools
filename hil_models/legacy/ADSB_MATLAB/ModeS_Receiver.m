function ModeS_Receiver(location,lat,lon,Rx)

% Copyright 2010, The MathWorks, Inc.

close all;
hfilt = dsp.FIRInterpolator(5);
searchThr = 5;

SQD = repmat({'      ',' ',' ',' ',' ',' ',' ',' ',rem(now,1),false},10,1);
f = figure('Position',[100 100 1040 400]);
uit = uitable(f,'Data',SQD,...
    'ColumnName',({'Aircraft ID','Altitude','N/S vel','E/W vel','Lat',...
    'Long','U/D vel','Flight ID','Time',' '}),...
    'ColumnWidth',{100,100,100,100,100,100,100,120,100,30},...
    'ColumnFormat',{'char','char','char','char',...
    'bank','bank','char','char','char','logical'},...
    'Position',[20 20 990 340],...
    'FontSize',16);

data2 = abs(step(hfilt,Rx));

[rxMsg, SQD2] = ModeS_DataSearch4(data2, searchThr, SQD,location,lat,lon);

if ~isequal(SQD,SQD2)
    SQD = SQD2;
    for idx = 1:10
        if isnumeric(SQD2{idx,9})
            if strcmp(SQD2{idx,1},'      ')
                SQD2{idx,9} = '    ';
            else
                SQD2{idx,9} = datestr(SQD2{idx,9},'HH:MM:SS');
            end
        end
    end
    set(uit,'Data',SQD2);
    drawnow;
    pause(0.5);
    for idx = 1:10
        SQD{idx,10} = false;
    end
end