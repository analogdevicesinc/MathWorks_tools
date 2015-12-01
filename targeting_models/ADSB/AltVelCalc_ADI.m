function [nv,ev,uv] = AltVelCalc_ADI(msg)
% Calculate velocity data from message bits
% Copyright 2010-2011, The MathWorks, Inc.

% Calculate East-West velocity
ewDir = msg(46);
if ewDir == 0
    ed = 1;
else
    ed = -1;
end
velBits = msg(47:56)';
ewVel = velBits*[512;256;128;64;32;16;8;4;2;1]-1;

% Calculate North-South velocity
nsDir = msg(57);
if nsDir == 0
    nd = 1;
else
    nd = -1;
end
velBits = msg(58:67)';
nsVel = velBits*[512;256;128;64;32;16;8;4;2;1]-1;

% Calculate rate of climb/descent
udDir = msg(69);
if udDir == 0
    ud = 1;
else
    ud = -1;
end
velBits = msg(70:78)';
udVel = (velBits*[256;128;64;32;16;8;4;2;1]-1)*64;

nv = nd*nsVel;
ev = ed*ewVel;
uv = ud*udVel;


