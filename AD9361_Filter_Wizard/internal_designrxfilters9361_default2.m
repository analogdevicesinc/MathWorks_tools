%  Copyright 2014(c) Analog Devices, Inc.
%
%  All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without modification,
%  are permitted provided that the following conditions are met:
%      - Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      - Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      - Neither the name of Analog Devices, Inc. nor the names of its
%        contributors may be used to endorse or promote products derived
%        from this software without specific prior written permission.
%      - The use of this software may or may not infringe the patent rights
%        of one or more patent holders.  This license does not release you
%        from the requirement that you obtain separate licenses from these
%        patent holders to use this software.
%      - Use of the software either in source or binary form or filter designs
%        resulting from the use of this software, must be connected to, run
%        on or loaded to an Analog Devices Inc. component.
%
%  THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%  INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
%  PARTICULAR PURPOSE ARE DISCLAIMED.
%
%  IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
%  RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
%  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
%  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
%  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% Inputs
% ============================================
% tohwTx = Parameters to set up the Tx hardware
%
% Outputs
%===============================================
% tohwRx = Parameters to set up the Rx hardware
%
function tohwRx = internal_designrxfilters9361_default2(tohwTx)

tohwRx = internal_designrxfilters9361_default(tohwTx.TXSAMP);
if tohwRx.BBPLL == tohwTx.BBPLL
    return;
else
    FIR = tohwTx.TF/tohwTx.TXSAMP;
    THB1 = tohwTx.T1/tohwTx.TF;
    THB2 = tohwTx.T2/tohwTx.T1;
    THB3 = tohwTx.DAC/tohwTx.T2;
    PLL_total = tohwTx.BBPLL/tohwTx.DAC;
    
    FIR_decim = FIR;
    rhb1 = THB1;
    rhb2 = THB2;
    if THB3 == 3
        rhb3 = 1;
        rdec3 = 3;
    elseif THB3 == 2
        rhb3 = 2;
        rdec3 = 1;
    else
        rhb3 = 1;
        rdec3 = 1;
    end
    HB_decim = rhb1*rhb2*rhb3*rdec3;
    PLL_multr = PLL_total;
    
    if PLL_multr > 64
        X = ['Date rate = ', num2str(tohwTx.TXSAMP), ' Hz. Tx BBPLL is too high for Rx to match.'];
        disp(X);
    end
end

Fout = tohwTx.TXSAMP;
Fadc = Fout * FIR_decim * HB_decim;
clkPLL = Fadc * PLL_multr;

Fpass = Fout/3;
Fstop = Fpass*1.25;
dBripple = 0.5;
dBstop = 80;
dBstop_FIR = 0;
phEQ = -1;
int_FIR = 1;
wnom = 0;

% Define the analog filters
if ~wnom
    wnom = 1.4*Fpass;
    div = ceil((clkPLL/wnom)*(log(2)/(2*pi)));
    caldiv = min(max(div,3),511);
    wc = (clkPLL/caldiv)*(log(2)/(2*pi));
else
    wc = wnom;
end

wTIA = wc*(2.5/1.4);

[b1,a1] = butter(1,2*pi*wTIA,'s');  % 1st order
[b2,a2] = butter(3,2*pi*wc,'s');    % 3rd order

% Define the digital filters with fixed coefficients
hb1 = 2^(-11)*[-8 0 42 0 -147 0 619 1013 619 0 -147 0 42 0 -8];
hb2 = 2^(-8)*[-9 0 73 128 73 0 -9];
hb3 = 2^(-4)*[1 4 6 4 1];
dec3 = 2^(-14)*[55 83 0 -393 -580 0 1914 4041 5120 4041 1914 0 -580 -393 0 83 55];

Hm1 = mfilt.firdecim(2,hb1);
Hm2 = mfilt.firdecim(2,hb2);
Hm3 = mfilt.firdecim(2,hb3);
Hm4 = mfilt.firdecim(3,dec3);

if license('test','fixed_point_toolbox') &&  license('checkout','fixed_point_toolbox')
    
    set(Hm1,'arithmetic','fixed');
    set(Hm2,'arithmetic','fixed');
    set(Hm3,'arithmetic','fixed');
    set(Hm4,'arithmetic','fixed');
    
    Hm1.InputWordLength = 16;
    Hm1.InputFracLength = 14;
    Hm1.FilterInternals = 'SpecifyPrecision';
    Hm1.OutputWordLength = 16;
    Hm1.OutputFracLength = 14;
    Hm1.CoeffWordLength = 16;
    
    Hm2.InputWordLength = 16;
    Hm2.InputFracLength = 14;
    Hm2.FilterInternals = 'SpecifyPrecision';
    Hm2.OutputWordLength = 16;
    Hm2.OutputFracLength = 14;
    Hm2.CoeffWordLength = 16;
    
    Hm3.InputWordLength = 4;
    Hm3.InputFracLength = 2;
    Hm3.FilterInternals = 'SpecifyPrecision';
    Hm3.OutputWordLength = 8;
    Hm3.OutputFracLength = 6;
    Hm3.CoeffWordLength = 16;
    
    Hm4.InputWordLength = 4;
    Hm4.InputFracLength = 2;
    Hm4.FilterInternals = 'SpecifyPrecision';
    Hm4.OutputWordLength = 16;
    Hm4.OutputFracLength = 14;
    Hm4.CoeffWordLength = 16;
    
end

% convert the enables into a string
enables = strrep(num2str([rhb1 rhb2 rhb3 rdec3]), ' ', '');
switch enables
    case '1111' % only RFIR
        Filter1 = 1;
    case '2111' % Hb1
        Filter1 = Hm1;
    case '1211' % Hb2
        Filter1 = Hm1;
    case '1121' % Hb3
        Filter1 = Hm1;
    case '2211' % Hb2,Hb1
        Filter1 = cascade(Hm2,Hm1);
    case '2121' % Hb3,Hb1
        Filter1 = cascade(Hm3,Hm1);
    case '2221' % Hb3,Hb2,Hb1
        Filter1 = cascade(Hm3,Hm2,Hm1);
    case '1113' % Dec3
        Filter1 = Hm4;
    case '2113' % Dec3,Hb1
        Filter1 = cascade(Hm4,Hm1);
    case '2213' % Dec3,Hb2,Hb1
        Filter1 = cascade(Hm4,Hm2,Hm1);
    case '1221' % Hb3,Hb2
        Filter1 = cascade(Hm3,Hm2);
    case '1213' % Dec3,Hb2
        Filter1 = cascade(Hm4,Hm2);
    otherwise
        error('ddcresponse:IllegalOption', 'At least one of the stages must be there.')
end

% Find out the best fit delay on passband
Nw = 2048;
w = zeros(1,Nw);
phi = zeros(1,Nw);
invariance = zeros(1,Nw);

w(1) = -Fpass;
for i = 2:(Nw)
    w(i) = w(1)-2*w(1)*i/(Nw);
end

response = analogresp('Rx',w,Fadc,b1,a1,b2,a2).*freqz(Filter1,w,Fadc);
for i = 1:(Nw)
    invariance(i) = real(response(i))^2+imag(response(i))^2;
end

phi(1)=atan2(imag(response(1)),real(response(1)));
for i = 2:(Nw)
    phi(i) = phi(i-1)+alias_b(atan2(imag(response(i)),real(response(i)))-phi(i-1),2*pi);
end

sigma = sum(invariance);
sigmax = sum(w.*invariance);
sigmay = sum(phi.*invariance);
sigmaxx = sum(w.*w.*invariance);
sigmaxy = sum(w.*phi.*invariance);
delta = sigma*sigmaxx-sigmax^2;
b = (sigma*sigmaxy-sigmax*sigmay)/delta;
if phEQ == 0 || phEQ == -1
    delay = -b/(2*pi);
else
    delay = phEQ*(1e-9);
end

% Design the PROG RX FIR
G = 16384;
clkRFIR = Fout*FIR_decim;
Gpass = floor(G*Fpass/clkRFIR);
Gstop=ceil(G*Fstop/clkRFIR);
Gpass = min(Gpass,Gstop-1);
fg = zeros(1,Gpass);
omega = zeros(1,Gpass);

% pass band
for i = 1:(Gpass+1)
    fg(i) = (i-1)/G;
    omega(i) = fg(i)*clkRFIR;
end
rg1 = analogresp('Rx',omega,Fadc,b1,a1,b2,a2).*freqz(Filter1,omega,Fadc);
rg2 = exp(-1i*2*pi*omega*delay);
rg = rg2./rg1;
w = abs(rg1)/(dBinv(dBripple/2)-1);

g = Gpass+1;
% stop band
for m = Gstop:(G/2)
    g = g+1;
    fg(g) = m/G;
    omega(g) = fg(g)*clkRFIR;
    rg(g) = 0;
end
wg1 = abs(analogresp('Rx',omega(Gpass+2:end),Fadc,b1,a1,b2,a2).*freqz(Filter1,omega(Gpass+2:end),Fadc));
wg2 = (wg1)/(dBinv(-dBstop));
wg3 = dBinv(dBstop_FIR);
wg = max(wg2,wg3);
grid = fg;
if phEQ == -1
    resp = abs(rg);
else resp = rg;
end
weight = [w wg];
weight = weight/max(weight);

% design RFIR filter
cr = real(resp);
B = 2;
F1 = grid(1:Gpass+1)*2;
F2 = grid(Gpass+2:end)*2;
A1 = cr(1:Gpass+1);
A2 = cr(Gpass+2:end);
W1 = weight(1:Gpass+1);
W2 = weight(Gpass+2:end);

% Determine the number of taps for RFIR
N = min(16*floor(Fadc/(2*Fout)),128);
tap_store = zeros(N/16,N);
dBripple_actual_vecotr = zeros(N/16,1);
dBstop_actual_vector = zeros(N/16,1);
i = 1;

while (1)
    if int_FIR
        d = fdesign.arbmag('N,B,F,A',N-1,B,F1,A1,F2,A2);
    else
        d = fdesign.arbmag('B,F,A,R');
        d.NBands = 2;
        d.B1Frequencies = F1;
        d.B1Amplitudes = A1;
        d.B1Ripple = db2mag(-dBstop);
        d.B2Frequencies = F2;
        d.B2Amplitudes = A2;
        d.B2Ripple = db2mag(-dBstop);
    end
    Hd = design(d,'equiripple','B1Weights',W1,'B2Weights',W2,'SystemObject',false);
    ccoef = Hd.Numerator;
    M = length(ccoef);
    
    if phEQ ~= -1
        sg = 0.5-grid(end:-1:1);
        sr = imag(resp(end:-1:1));
        sw = weight(end:-1:1);
        F3 = sg(1:G/2-Gstop+1)*2;
        F4 = sg(G/2-Gstop+2:end)*2;
        A3 = sr(1:G/2-Gstop+1);
        A4 = sr(G/2-Gstop+2:end);
        W3 = sw(1:G/2-Gstop+1);
        W4 = sw(G/2-Gstop+2:end);
        if int_FIR
            d2 = fdesign.arbmag('N,B,F,A',N-1,B,F3,A3,F4,A4);
        else
            d2 = fdesign.arbmag('N,B,F,A',M-1,B,F3,A3,F4,A4);
        end
        Hd2 = design(d2,'equiripple','B1Weights',W3,'B2Weights',W4,'SystemObject',false);
        scoef = Hd2.Numerator;
        for k = 1:length(scoef)
            scoef(k) = -scoef(k)*(-1)^(k-1);
        end
    else
        scoef = 0;
    end
    tap_store(i,1:M)=ccoef+scoef;
    
    Hmd = mfilt.firdecim(FIR_decim,tap_store(i,1:M));
    if license('test','fixed_point_toolbox') &&  license('checkout','fixed_point_toolbox')
        set(Hmd,'arithmetic','fixed');
        Hmd.InputWordLength = 16;
        Hmd.InputFracLength = 14;
        Hmd.FilterInternals = 'SpecifyPrecision';
        Hmd.OutputWordLength = 12;
        Hmd.OutputFracLength = 10;
        Hmd.CoeffWordLength = 16;
    end
    rxFilters=cascade(Filter1,Hmd);
    
    % quantitative values about actual passband and stopband
    rg_pass = abs(analogresp('Rx',omega(1:Gpass+1),Fadc,b1,a1,b2,a2).*freqz(rxFilters,omega(1:Gpass+1),Fadc));
    rg_stop = abs(analogresp('Rx',omega(Gpass+2:end),Fadc,b1,a1,b2,a2).*freqz(rxFilters,omega(Gpass+2:end),Fadc));
    dBripple_actual_vecotr(i) = mag2db(max(rg_pass))-mag2db(min(rg_pass));
    dBstop_actual_vector(i) = -mag2db(max(rg_stop));
    
    if int_FIR == 0
        h = tap_store(1,1:M);
        break
    elseif dBripple_actual_vecotr(1) > dBripple || dBstop_actual_vector(1) < dBstop
        h = tap_store(1,1:N);
        break
    elseif dBripple_actual_vecotr(i) > dBripple || dBstop_actual_vector(i) < dBstop
        h = tap_store(i-1,1:N+16);
        break
    else
        N = N-16;
        i = i+1;
    end
end

Hmd = mfilt.firdecim(FIR_decim,h);
if license('test','fixed_point_toolbox') &&  license('checkout','fixed_point_toolbox')
    set(Hmd,'arithmetic','fixed');
    Hmd.InputWordLength = 16;
    Hmd.InputFracLength = 14;
    Hmd.FilterInternals = 'SpecifyPrecision';
    Hmd.OutputWordLength = 12;
    Hmd.OutputFracLength = 10;
    Hmd.CoeffWordLength = 16;
end

aTFIR = 1 + ceil(log2(max(Hmd.Numerator)));
switch aTFIR
    case 2
        gain = +6;
    case 1
        gain = 0;
    case 0
        gain = -6;
    otherwise
        gain = -12;
end
if aTFIR > 2
    gain = +6;
end
bTFIR = 16 - aTFIR;
rfirtaps = Hmd.Numerator.*(2^bTFIR);

if length(rfirtaps) < 128
    rfirtaps = [rfirtaps,zeros(1,128-length(rfirtaps))];
end

tohwRx.RXSAMP = Fout;
tohwRx.RF = Fout * FIR_decim;
tohwRx.R1 = tohwRx.RF * rhb1;
tohwRx.R2 = tohwRx.R1 * rhb2;
tohwRx.ADC = Fadc;
tohwRx.BBPLL = clkPLL;
tohwRx.Coefficient = rfirtaps;
tohwRx.CoefficientSize = length(h);
tohwRx.Decimation = FIR_decim;
tohwRx.Gain = gain;
tohwRx.RFBandwidth = round(Fpass*2);