function [rxMsg, SQ] = ModeS_ReadMsg4(Yb,SQ)
% ModeS_ReadMsg.m

% Copyright 2010-2011, The MathWorks, Inc.

rxMsgCount = 0;
rxMsg = '8D00000000000000000000000000';
% bLen = 75;
% syncBuffer = zeros(bLen,1); % Buffer to use to correlate sync
% searchBuffer = zeros(bLen,1);   % Buffer to use to search for the sync peak
% msgBuffer = zeros(112*25/2 + 200,1);  % Buffer to store the message data

sync = [ones(6,1);-1*ones(6,1);ones(6,1);-1*ones(7,1);...
-1*ones(6,1);-1*ones(6,1);-1*ones(6,1);ones(7,1);...
-1*ones(6,1);ones(6,1);-1*ones(6,1);-1*ones(7,1)];

% possibleSync = 0;
% decodeIndex = 1e8;

% For the data set smooth data, fill buffer and calculate noise
% floor. Compute the sync correlation
nf2 = 2*filter(0.01333*ones(75,1),1,Yb);
ycorr = filter(flipud(sync),1,Yb);

possSyncStart = find(ycorr>nf2);

prev = -74;
for kk=1:length(possSyncStart)
    ii = possSyncStart(kk);
    if ((ii+74)<=numel(ycorr) && (ii>(prev+74)))
        prev = ii;
        searchBuffer = ycorr(ii:ii+74);
        decodeIndex = min(find(searchBuffer == max(searchBuffer))) + 25 + ii;
        if ((decodeIndex>0) && ((decodeIndex+1499)<=numel(Yb)))
            msgBuffer = Yb(decodeIndex:decodeIndex+1499);
            if (max(msgBuffer)/mean(msgBuffer)) < 5
                [goodCRC,bits] = ModeS_BitDecode4(msgBuffer);
                if goodCRC == 1 || goodCRC == 2
                    c = reshape(bits,4,numel(bits)/4);
                    d = bin2dec(num2str(c'));
                    rxBytes = dec2hex(d)';
                    currID = rxBytes(3:8);
                    newIdx = 0;
                    for idx = 1:10,
                        if strcmp(SQ{idx,1},currID), 
                            newIdx = idx;
                        end
                    end
                    if newIdx == 0
                        [~,newIdx] = min([SQ{:,9}]);
                        SQ{newIdx,1} = currID;
                        SQ{newIdx,2} = ' ';
                        SQ{newIdx,3} = ' ';
                        SQ{newIdx,4} = ' ';
                        SQ{newIdx,5} = ' ';
                        SQ{newIdx,6} = ' ';
                        SQ{newIdx,7} = ' ';
                        SQ{newIdx,8} = ' ';
                        SQ{newIdx,9} = rem(now,1);
                        SQ{newIdx,10} = true;
                    end
                    SQ{newIdx,1} = currID;
                    SQ{newIdx,10} = true;
                end
                if goodCRC == 1
%                     s1 = sprintf('Aircraft ID %s      Long Message CRC: %s', rxBytes(3:8), rxBytes);
                    if rxBytes(9) == '9' && rxBytes(10) == '9'
                        [nV, eV, uV] = AltVelCalc(rxBytes);
                        SQ{newIdx,3} = nV;
                        SQ{newIdx,4} = eV;
                        SQ{newIdx,7} = uV;
                        SQ{newIdx,9} = rem(now,1);
                        rxMsgCount = rxMsgCount + 1;
                        rxMsg(rxMsgCount,:) = rxBytes;
                    elseif rxBytes(9) == '5' || rxBytes(9) == '6'
                        [lat, long, alt] = LatLongCalcSingle(rxBytes);
                        SQ{newIdx,2} = alt;
                        SQ{newIdx,5} = lat;
                        SQ{newIdx,6} = long;
                        SQ{newIdx,9} = rem(now,1);
                        rxMsgCount = rxMsgCount + 1;
                        rxMsg(rxMsgCount,:) = rxBytes;
                    elseif rxBytes(9) == '9' && rxBytes(10) =='0'
                        [lat, long, alt] = LatLongCalcSingle(rxBytes);
                        SQ{newIdx,2} = alt;
                        SQ{newIdx,5} = lat;
                        SQ{newIdx,6} = long;
                        SQ{newIdx,9} = rem(now,1);
                        rxMsgCount = rxMsgCount + 1;
                        rxMsg(rxMsgCount,:) = rxBytes;
                    elseif rxBytes(9) == '2'
                        x=dec2bin(hex2dec(rxBytes(11:22)),48);
                        msgInt = zeros(1,8);
                        for ii = 1:8
                            msgInt(ii) = 1+bin2dec(x(1+(ii-1)*6:ii*6));
                        end
                        charCode = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ                     0123456789      ';
                        FlightID = [charCode(msgInt(1)) charCode(msgInt(2)) charCode(msgInt(3)) charCode(msgInt(4))... 
                        charCode(msgInt(5)) charCode(msgInt(6)) charCode(msgInt(7)) charCode(msgInt(8))];
                        SQ{newIdx,8} = FlightID;
                        SQ{newIdx,9} = rem(now,1);
                    end
                elseif goodCRC == 2
%                     s1 = sprintf('Aircraft ID %s     Short Message CRC: %s', rxBytes(3:8), rxBytes);
                    SQ{newIdx,9} = rem(now,1);
                end
            end
        end
    end
end
    
