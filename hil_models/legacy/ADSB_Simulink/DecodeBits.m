function DecodeBits(bits)

% Copyright 2010, The MathWorks, Inc.

c = reshape(bits(1:112),4,28);
d = bin2dec(num2str(c'));
rxBytes = dec2hex(d)';
s1 = sprintf('Aircraft ID %s      Long Message CRC: %s', rxBytes(3:8), rxBytes);
disp(s1)
if rxBytes(9) == '9' && rxBytes(10) == '9'
    [nV, eV, aV] = AltVelCalc(rxBytes);
elseif rxBytes(9) == '5' || rxBytes(9) == '6'
    [alt, lat, long] = LatLongCalcSingle(rxBytes);
elseif rxBytes(9) == '9' && rxBytes(10) =='0'
    [alt, lat, long] = LatLongCalcSingle(rxBytes);
end
