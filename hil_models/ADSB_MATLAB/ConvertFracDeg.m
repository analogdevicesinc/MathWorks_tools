function [dd,mm,ss] = ConvertFracDeg(degIn)

% Copyright 2010, The MathWorks, Inc.

if degIn>0
    dd=floor(degIn);
else
    dd=ceil(degIn);
end
fracd = abs(degIn-dd);
if dd==0
    if degIn>0
        mm=floor(fracd*60);
        fracm = fracd-(mm/60);
    else
        mm=-floor(fracd*60);
        fracm = fracd+(mm/60);
    end
else
    mm=floor(fracd*60);
    fracm = fracd-(mm/60);
end
if (dd==0 && mm==0)
    if degIn>0
        ss=(fracm*3600);
    else
        ss=-(fracm*3600);
    end
else
    ss=(fracm*3600);
end
