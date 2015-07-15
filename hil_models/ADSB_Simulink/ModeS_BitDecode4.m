function [goodCRC, bits] = ModeS_BitDecode4(yIn)
% compile with >> codegen -o ModeS_BitDecode7MX -args {(zeros(1500,1))} ModeS_BitDecode7
%#codegen

% Copyright 2010-2011, The MathWorks, Inc.

bits = false(1,112);
diffVals = zeros(1,112);
idx=round(12:12.5:1500);
b1 = [ones(6,1);zeros(6,1)];
b0 = flipud(b1);

matchedFilter = filter(b0,1,yIn);
thr = filter(b1,1,yIn);

for ii = 1:112
    if matchedFilter(idx(ii)) < thr(idx(ii))
        bits(ii) = false;
    else
        bits(ii) = true;
    end
    diffVals(ii) = abs(matchedFilter(idx(ii))-thr(idx(ii)));
end

encoded = crc24f(bits(1:88));
encoded56 = crc24f(bits(1:32));

if all(bits(89:112) == encoded(89:112))
    goodCRC = 1;
elseif all(bits(33:56) == encoded56(33:56))
    goodCRC = 2;
else
    goodCRC = 0;
end

function y = crc24f(m)
%#codegen

persistent hcrc;

if isempty(hcrc)
    g = logical([1 0 0 1 0 0 0 0 0 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1]);
    gflip = fliplr(g);
    hcrc = comm.CRCGenerator(gflip);
end
reset(hcrc);
y = step(hcrc,m');
y = y';