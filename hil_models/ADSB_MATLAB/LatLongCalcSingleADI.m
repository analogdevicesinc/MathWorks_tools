function [Rlat,Rlon,alt] = LatLongCalcSingleADI(msg1,location,lat,lon)

% Copyright 2010, The MathWorks, Inc.

a = hex2dec(msg1');
b = dec2bin(a);
bin = reshape(b',1,length(msg1)*4);

aircraftID = msg1(3:8);

% Calculate altitude from 11 bits
q = bin(48);
if q == '0'
    af = 100;
else
    af = 25;
end
alt = bin2dec(strcat(bin(41:47),bin(49:52)))*af;

evenOdd1 = bin(54);
if evenOdd1 == '0'
    evenOdd1 = 'Even';
else
    evenOdd1 = 'Odd';
end

% Extract latitude and longitude bits
la1 = bin2dec(bin(55:71));
lo1 = bin2dec(bin(72:88));

% disp(sprintf('Plane is at altitude %d\nLatitude value: %d\nLongitude value: %d', alt, la1, lo1));
% disp(sprintf('Aircraft ID %s is at altitude %d', aircraftID, alt));

% Technically you need both even and odd messages to calculate location.lat/long
% unambiguously. For this code, use a single message and then check to see
% if the location.lat/long values are reasonable. If not, change the location.lat/long base
% factors (a1, a2, etc.) and recompute.

% Calculate latitude from 17 bits
if strcmp(evenOdd1,'Even')
    Rlat = location.Dlat0*(location.a1 + la1/131072);
else
    Rlat = location.Dlat1*(location.a2 + la1/131072);
end

% Compare latitude to known location. If it's off by more than two degrees,
% use new base factors.
if Rlat > lat+2
    if strcmp(evenOdd1,'Even')
        Rlat = location.Dlat0*(location.a1 - 1 + la1/131072);
    else
        Rlat = location.Dlat1*(location.a2 - 1 + la1/131072);
    end
elseif Rlat < lat-2
    if strcmp(evenOdd1,'Even')
        Rlat = location.Dlat0*(location.a1 + 1 + la1/131072);
    else
        Rlat = location.Dlat1*(location.a2 + 1 + la1/131072);
    end
end

% Calculate latitude from 17 bits
if strcmp(evenOdd1,'Even')
    Rlon = location.Dlon0*(location.a3 + lo1/131072);
else
    Rlon = location.Dlon1*(location.a4 + lo1/131072);
end

% Compare longitude to known location. If it's off by more than two
% degrees, use new base factors.
if Rlon > lon+2
    if strcmp(evenOdd1,'Even')
        Rlon = location.Dlon0*(location.a3 - 1 + lo1/131072);
    else
        Rlon = location.Dlon1*(location.a4 - 1 + lo1/131072);
    end
elseif Rlon < lon-2
    if strcmp(evenOdd1,'Even')
        Rlon = location.Dlon0*(location.a3 + 1 + lo1/131072);
    else
        Rlon = location.Dlon1*(location.a4 + 1 + lo1/131072);
    end
end

[ddLat,mmLat,ssLat]=ConvertFracDeg(Rlat);
[ddLong,mmLong,ssLong]=ConvertFracDeg(Rlon);
fprintf(sprintf('Aircraft ID %s is at latitude %d %d %4.1f, longitude %d %d %4.1f\n', aircraftID, ddLat, mmLat, ssLat, ddLong, mmLong, ssLong));