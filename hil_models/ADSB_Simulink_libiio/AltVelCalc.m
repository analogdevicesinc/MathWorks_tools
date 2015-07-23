function [nv,ev,uv] = AltVelCalc(msg)

% Copyright 2010-2011, The MathWorks, Inc.

%AltVelCalc
% msg = '8DABDEEC99153E09802C013F4BDF';
% msg = '8DA66A1399104CAA80A406129D1D';
% msg = '8DAA8A83991502A7000411EE1091';
% msg = '8D40067899050CA680050D26CFB1';
% msg = '8D4CA74E9914C0AC80040F8D6965';
% msg = '8D80043C9904E4A7A0070D597008';
% msg = '8DABC6519904AFAC000513E3A869';
% msg = '8D4B187E9944CDAAA8040F67994E';
% msg = '8DA6CC41990488AE00070049848E';
% msg = '8DA9BF4B99948BB0A0040E5828F0';
% msg = '8D40067899050CA680050D26CFB1';
% msg = '8DA3CC3790C380976B152295D11F';  % Bad results
% msg = '8DA3CC37994483ACB004003CB62A';


a = hex2dec(msg');
b = dec2bin(a);
bin = reshape(b',1,length(msg)*4);

aircraftID = msg(3:8);

ewDir = bin(46);
if ewDir == '0'
    EW = 'East';
    ed = 1;
else
    EW = 'West';
    ed = -1;
end
ewVel = bin2dec(bin(47:56))-1;

nsDir = bin(57);
if nsDir == '0'
    NS = 'North';
    nd = 1;
else
    NS = 'South';
    nd = -1;
end
nsVel = bin2dec(bin(58:67))-1;

udDir = bin(69);
if udDir == '0'
    UD = 'Up';
    ud = 1;
else
    UD = 'Down';
    ud = -1;
end
udVel = (bin2dec(bin(70:78))-1)*64;

speed = sqrt(ewVel^2+nsVel^2);   % Speed in knots

% disp(sprintf('Aircraft ID %s is traveling at %f knots\nDirection %s at %f knots, direction %s at %f knots ', aircraftID, speed, EW, ewVel, NS, nsVel));
% disp(sprintf('Aircraft ID %s is going %s at %f feet/min\n', aircraftID, UD, udVel));

nv = nd*nsVel;
ev = ed*ewVel;
uv = ud*udVel;
