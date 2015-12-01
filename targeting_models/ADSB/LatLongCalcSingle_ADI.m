function [Rlat,Rlon,alt] = LatLongCalcSingle_ADI(msg, inputLat, inputLong)
% Calculate latitude, longitude and altitude from message bits
% Copyright 2010, The MathWorks, Inc.

persistent NL
persistent latzones
persistent Dlat0
persistent Dlat1
persistent latOffset0
persistent latOffset1

if isempty(NL)
    Dlat0 = 360/(4*15-0);
    latOffset0 = floor(inputLat/Dlat0);
    Dlat1 = 360/(4*15-1);
    latOffset1 = floor(inputLat/Dlat1);
    NL=2:59;
    latzones = [(180/pi)*acos(sqrt((1-cos(pi/2/15))./(1-cos(2*pi./NL)))) 0];
end

% Altitude calculation
q = msg(48);
if q == 0
    af = 100;
else
    af = 25;
end
altBits=[msg(41:47);msg(49:52)]';
alt = altBits*[1024;512;256;128;64;32;16;8;4;2;1]*af - 1000;

evenOdd1 = msg(54);
latBits = msg(55:71)';
longBits = msg(72:88)';
la1 = latBits*[65536;32768;16384;8192;4096;2048;1024;512;256;128;64;32;16;8;4;2;1];
lo1 = longBits*[65536;32768;16384;8192;4096;2048;1024;512;256;128;64;32;16;8;4;2;1];

% Technically you need both even and odd messages to calculate lat/long
% unambiguously. For this code, use a single message and then check to see
% if the lat/long values are reasonable. If not, change the lat/long base
% factors (LL.a1, LL.a2, etc.) and recompute.

% Latitude calculation
if evenOdd1 == 0
    Rlat = Dlat0*(latOffset0 + la1/131072);
else
    Rlat = Dlat1*(latOffset1 + la1/131072);
end

% Compare latitude to known location. If it's off by more than two degrees,
% use new base factors.
if Rlat > inputLat+2
    if strcmp(evenOdd1,'Even')
        Rlat = Dlat0*(latOffset0 - 1 + la1/131072);
    else
        Rlat = Dlat1*(latOffset1 - 1 + la1/131072);
    end
elseif Rlat < inputLat-2
    if strcmp(evenOdd1,'Even')
        Rlat = Dlat0*(latOffset0 + 1 + la1/131072);
    else
        Rlat = Dlat1*(latOffset1 + 1 + la1/131072);
    end
end

% Based on latitude, calculate longitude
NL0 = find(latzones<Rlat,1,'first');
ni0 = NL0;
ni1 = NL0 - 1;

Dlon0 = 360/ni0;
longOffset0 = floor(inputLong/Dlon0);
Dlon1 = 360/ni1;
longOffset1 = floor(inputLong/Dlon1);

if evenOdd1 == 0
    Rlon = Dlon0*(longOffset0 + lo1/131072);
else
    Rlon = Dlon1*(longOffset1 + lo1/131072);
end

% Compare longitude to known location. If it's off by more than two 
% degrees, use new base factors.
if Rlon > inputLong+2
    if strcmp(evenOdd1,'Even')
        Rlon = Dlon0*(longOffset0 - 1 + lo1/131072);
    else
        Rlon = Dlon1*(longOffset1 - 1 + lo1/131072);
    end
elseif Rlon < inputLong-2
    if strcmp(evenOdd1,'Even')
        Rlon = Dlon0*(longOffset0 + 1 + lo1/131072);
    else
        Rlon = Dlon1*(longOffset1 + 1 + lo1/131072);
    end
end

% disp(sprintf('Plane is at altitude %d\nLatitude value: %d\nLongitude value: %d', alt, la1, lo1));

% GoogleMap(aircraftID, alt1, Rlat, Rlon)