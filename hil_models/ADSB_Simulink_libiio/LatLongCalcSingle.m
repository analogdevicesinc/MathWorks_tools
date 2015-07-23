function [Rlat,Rlon,alt] = LatLongCalcSingle(msg1)

% Copyright 2010, The MathWorks, Inc.

% msg1 = '8d00000060c38037389c0e';  % From dat1090_558.mat
% msg1 = '8d00000060c387be2f010e';
% msg1 = '8D00000060C377BA050257E9ED2B';
% msg1 = '8DA19E9F5017385A14972C52A6E4';
% msg1 = '8DAA8A8360C377BA050257E9ED2B';
% msg1 = '8DAA8A8360C370328A9D465859A0';
% msg1 = '8DA66A13604B501232B9B99ADF83';
% msg1 = '8DA66A13604B301276B9B184ECF9';
% msg1 = '8DA19E9F5017385A14972C52A6E4';
% msg1 = '8D40067860C380460CB5B2EB8D3A';
% msg1 = '8D40067860C38009169B555F8602';
% msg1 = '8D40067860C38791B7009F951703';
% msg1 = '8D80043C68CD8091591227B39B4B';
% msg1 = '8D80043C68C93048989EC9A068CA';
% msg1 = '8D4B187E60C3805296A6FB255599';
% msg1 = '8D4B187E60ADA797F0F8A564914B';
% msg1 = '8DA6CC4190C380832AA8128A8921';
% msg1 = '8DA3CC3790C380976B152295D11F';  

a = hex2dec(msg1');
b = dec2bin(a);
bin = reshape(b',1,length(msg1)*4);

aircraftID = msg1(3:8);

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
la1 = bin2dec(bin(55:71));
lo1 = bin2dec(bin(72:88));

% disp(sprintf('Plane is at altitude %d\nLatitude value: %d\nLongitude value: %d', alt, la1, lo1));
% disp(sprintf('Aircraft ID %s is at altitude %d', aircraftID, alt));

if strcmp(evenOdd1,'Even')
    Dlat0 = 360/(4*15-0);
    Rlat = Dlat0*(7 + la1/131072);
else
    Dlat1 = 360/(4*15-1);
    Rlat = Dlat1*(6 + la1/131072);
end

NL=2:59;
latzones = [(180/pi)*acos(sqrt((1-cos(pi/2/15))./(1-cos(2*pi./NL)))) 0];

NL0 = find(latzones<Rlat,1,'first');
NL1 = find(latzones<Rlat,1,'first');

ni0 = NL0;
ni1 = NL1 - 1;

Dlon0 = 360/ni0;
Dlon1 = 360/ni1;

if strcmp(evenOdd1,'Even')
    Rlon = Dlon0*(-9 + lo1/131072);
else
    Rlon = Dlon1*(-9 + lo1/131072);
end

% disp(sprintf('Aircraft ID %s is at latitude %d %d %4.1f, longitude %d %d %4.1f\n', aircraftID, degrees2dms(Rlat), degrees2dms(Rlon)));

% GoogleMap(aircraftID, alt1, Rlat, Rlon)