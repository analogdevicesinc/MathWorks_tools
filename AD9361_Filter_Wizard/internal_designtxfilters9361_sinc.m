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

% Inputs (structure containing the following fields)
% ============================================
% data_rate  = Input sample data rate (in Hz)
% FIR_interp = FIR interpolation factor
% HB_interp  = half band filters interpolation factor
% DAC_mult   = DAC to ADC ratio
% PLL_mult   = PLL multiplication
% Fpass      = passband frequency (in Hz)
% Fstop      = stopband frequency (in Hz)
% dBripple   = max ripple allowed in passband (in dB)
% dBstop     = min attenuation in stopband (in dB)
% dBstop_FIR = min rejection that TFIR is required to have (in dB)
% phEQ       = Phase Equalization on (not -1)/off (-1)
% int_FIR    = Use AD9361 FIR on (1)/off (0)
% wnom       = analog cutoff frequency (in Hz)
% converter_rate = converter (DAC/ADC) sampling rate (in Hz)
% clkPLL     = PLL frequency (in HZ)
%
% Outputs (structure containing the following fields)
% ===============================================
% tfirtaps         = fixed point coefficients for PROG TX FIR
% txFilters        = system object for visualization (does not include analog filters)
% dBripple_actual  = actual passband ripple
% dBstop_actual    = actual stopband attentuation
% delay            = actual delay used in phase equalization
% webinar          = initialization for SimRF FMCOMMS2 Tx model

function result = internal_designtxfilters9361_sinc(input)

if ~input.wnom
    input.wnom = 1.6*input.Fpass;
    div = ceil((input.clkPLL/input.wnom)*(log(2)/(2*pi)));
    caldiv = min(max(div,3),511);
    wc = (input.clkPLL/caldiv)*(log(2)/(2*pi));
else
    wc = input.wnom;
end

wreal = wc*(5.0/1.6);

% Define the analog filters (for design purpose)
[b1,a1] = butter(3,2*pi*wc,'s');     % 3rd order
[b2,a2] = butter(1,2*pi*wreal,'s');  % 1st order

% Digital representation of the analog filters (It is an approximation for group delay calculation only)
[z1,p1,k1] = butter(3,wc/(input.converter_rate/2),'low');
[sos1,g1] = zp2sos(z1,p1,k1);
Hd1 = dfilt.df2tsos(sos1,g1);
[z2,p2,k2] = butter(1,wreal/(input.converter_rate/2),'low');
[sos2,g2] = zp2sos(z2,p2,k2);
Hd2 = dfilt.df2tsos(sos2,g2);
Hanalog = cascade(Hd1,Hd2);

% Define the digital filters with fixed coefficients
hb1 = 2^(-14)*[-53 0 313 0 -1155 0 4989 8192 4989 0 -1155 0 313 0 -53];
hb2 = 2^(-8)*[-9 0 73 128 73 0 -9];
hb3 = 2^(-2)*[1 2 1];
int3 = (1/3)*2^(-13)*[36 -19 0 -156 -12 0 479 223 0 -1215 -993 0 3569 6277 8192 6277 3569 0 -993 -1215 0 223 479 0 -12 -156 0 -19 36];

Hm1 = mfilt.firinterp(2,hb1);
Hm2 = mfilt.firinterp(2,hb2);
Hm3 = mfilt.firinterp(2,hb3);
Hm4 = mfilt.firinterp(3,int3);

if license('test','fixed_point_toolbox') && license('checkout','fixed_point_toolbox')
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
enables = strrep(num2str([input.HB1 input.HB2 input.HB3]), ' ', '');
switch enables
    case '111' % only TFIR
        Filter1 = 1;
    case '211' % Hb1
        Filter1 = Hm1;
    case '221' % Hb1,Hb2
        Filter1 = cascade(Hm1,Hm2);
    case '222' % Hb1,Hb2,Hb3
        Filter1 = cascade(Hm1,Hm2,Hm3);
    case '113' % Int3
        Filter1 = Hm4;
    case '213' % Hb1,Int3
        Filter1 = cascade(Hm1,Hm4);
    case '223' % Hb1,Hb2,Int3
        Filter1 = cascade(Hm1,Hm2,Hm4);
    otherwise
        error('ddcresponse:IllegalOption', 'At least one of the stages must be there.')
end

% Modify the enables string to maintain old webinar struct compat.
% This should be removed once the SimRF model doesn't rely on the four
% character string and instead can use the straight halfband values.
if input.HB3 == 3
    enables(end) = '1';
    enables(end+1) = '3';
else
    enables(end+1) = '1';
end

% Find out the best fit delay on passband
Nw = 2048;
w = zeros(1,Nw);
phi = zeros(1,Nw);
invariance = zeros(1,Nw);

w(1) = -input.Fpass;
for i = 2:(Nw)
    w(i) = w(1)-2*w(1)*i/(Nw);
end

response = freqz(Filter1,w,input.converter_rate).*analogresp('Tx',w,input.converter_rate,b1,a1,b2,a2);
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
if input.phEQ == 0 || input.phEQ == -1
    delay = -b/(2*pi);
else
    delay = input.phEQ*(1e-9);
end

% Design the PROG TX FIR
G = 16384;
clkTFIR = input.data_rate*input.FIR_interp;
Gpass = floor(G*input.Fpass/clkTFIR);
Gstop=ceil(G*input.Fstop/clkTFIR);
Gpass = min(Gpass,Gstop-1);
fg = zeros(1,Gpass);
omega = zeros(1,Gpass);

% passband
for i = 1:(Gpass+1)
    fg(i) = (i-1)/G;
    omega(i) = fg(i)*clkTFIR;
end
rg1 = freqz(Filter1,omega,input.converter_rate).*analogresp('Tx',omega,input.converter_rate,b1,a1,b2,a2);
rg2 = exp(-1i*2*pi*omega*delay);
rg = rg2./rg1;
w = abs(rg1)/(dBinv(input.dBripple/2)-1);

g = Gpass+1;
% stop band
for m = Gstop:(G/2)
    g = g+1;
    fg(g) = m/G;
    omega(g) = fg(g)*clkTFIR;
    rg(g) = 0;
end
wg1 = abs(freqz(Filter1,omega(Gpass+2:end),input.converter_rate).*analogresp('Tx',omega(Gpass+2:end),input.converter_rate,b1,a1,b2,a2));
wg2 = (sqrt(input.FIR_interp)*wg1)/(dBinv(-input.dBstop));
wg3 = dBinv(input.dBstop_FIR);
wg = max(wg2,wg3);
grid = fg;
if input.phEQ == -1
    resp = abs(rg);
else resp = rg;
end
weight = [w wg];
weight = weight/max(weight);

% design TFIR filter
cr = real(resp);
B = 2;
F1 = grid(1:Gpass+1)*2;
F2 = grid(Gpass+2:end)*2;
A1 = cr(1:Gpass+1);
A2 = cr(Gpass+2:end);
W1 = weight(1:Gpass+1);
W2 = weight(Gpass+2:end);

% Determine the number of taps for TFIR
switch input.FIR_interp
    case 1
        Nmax = 64;
    case 2
        Nmax = 128;
    case 4
        Nmax = 128;
end

N = min(16*floor(input.converter_rate*input.DAC_mult/(2*input.data_rate)),Nmax);
tap_store = zeros(N/16,N);
dBripple_actual_vector = zeros(N/16,1);
dBstop_actual_vector = zeros(N/16,1);
i = 1;

while (1)
    if input.int_FIR
        d = fdesign.arbmag('N,B,F,A',N-1,B,F1,A1,F2,A2);
    else
        d = fdesign.arbmag('B,F,A,R');
        d.NBands = 2;
        d.B1Frequencies = F1;
        d.B1Amplitudes = A1;
        d.B1Ripple = db2mag(-input.dBstop);
        d.B2Frequencies = F2;
        d.B2Amplitudes = A2;
        d.B2Ripple = db2mag(-input.dBstop);
    end
    Hd = design(d,'equiripple','B1Weights',W1,'B2Weights',W2,'SystemObject',false);
    ccoef = Hd.Numerator;
    M = length(ccoef);

    if input.phEQ ~= -1
        sg = 0.5-grid(end:-1:1);
        sr = imag(resp(end:-1:1));
        sw = weight(end:-1:1);
        F3 = sg(1:G/2-Gstop+1)*2;
        F4 = sg(G/2-Gstop+2:end)*2;
        A3 = sr(1:G/2-Gstop+1);
        A4 = sr(G/2-Gstop+2:end);
        W3 = sw(1:G/2-Gstop+1);
        W4 = sw(G/2-Gstop+2:end);
        if input.int_FIR
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

    Hmd = mfilt.firinterp(input.FIR_interp,tap_store(i,1:M));
    if license('test','fixed_point_toolbox') && license('checkout','fixed_point_toolbox')
        set(Hmd,'arithmetic','fixed');
        Hmd.InputWordLength = 16;
        Hmd.InputFracLength = 14;
        Hmd.FilterInternals = 'SpecifyPrecision';
        Hmd.OutputWordLength = 12;
        Hmd.OutputFracLength = 10;
        Hmd.CoeffWordLength = 16;
    end
    txFilters=cascade(Hmd,Filter1);

    % quantitative values about actual passband and stopband
    rg_pass = abs(freqz(txFilters,omega(1:Gpass+1),input.converter_rate).*analogresp('Tx',omega(1:Gpass+1),input.converter_rate,b1,a1,b2,a2));
    rg_stop = abs(freqz(txFilters,omega(Gpass+2:end),input.converter_rate).*analogresp('Tx',omega(Gpass+2:end),input.converter_rate,b1,a1,b2,a2));
    dBripple_actual_vector(i) = mag2db(max(rg_pass))-mag2db(min(rg_pass));
    dBstop_actual_vector(i) = -mag2db(max(rg_stop));

    if input.int_FIR == 0
        h = tap_store(1,1:M);
        dBripple_actual = dBripple_actual_vector(1);
        dBstop_actual = dBstop_actual_vector(1);
        break
    elseif dBripple_actual_vector(1) > input.dBripple || dBstop_actual_vector(1) < input.dBstop
        h = tap_store(1,1:N);
        dBripple_actual = dBripple_actual_vector(1);
        dBstop_actual = dBstop_actual_vector(1);
        break
    elseif dBripple_actual_vector(i) > input.dBripple || dBstop_actual_vector(i) < input.dBstop
        h = tap_store(i-1,1:N+16);
        dBripple_actual = dBripple_actual_vector(i-1);
        dBstop_actual = dBstop_actual_vector(i-1);
        break
    else
        N = N-16;
        i = i+1;
    end
end

if input.int_FIR == 1 && input.FIR_interp == 2
    R = rem(length(h),32);
    if R ~= 0
        h = [zeros(1,8),h,zeros(1,8)];
    end
elseif input.int_FIR == 1 && input.FIR_interp == 4
    R = rem(length(h),64);
    if R ~= 0
        newlength = ceil(length(h)/64)*64;
        addlength = (newlength-length(h))/2;
        h = [zeros(1,addlength),h,zeros(1,addlength)];
    end
end

Hmd = mfilt.firinterp(input.FIR_interp,h);
if license('test','fixed_point_toolbox') && license('checkout','fixed_point_toolbox')
    set(Hmd,'arithmetic','fixed');
    Hmd.InputWordLength = 16;
    Hmd.InputFracLength = 14;
    Hmd.FilterInternals = 'SpecifyPrecision';
    Hmd.OutputWordLength = 12;
    Hmd.OutputFracLength = 10;
    Hmd.CoeffWordLength = 16;
end
txFilters=cascade(Hmd,Filter1);

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
if input.FIR_interp == 2
    gain = gain+6;
elseif input.FIR_interp == 4
    gain = gain+12;
end
if gain > 0
    gain = 0;
elseif gain < -6
    gain = -6;
end
bTFIR = 16 - aTFIR;
tfirtaps = Hmd.Numerator.*(2^bTFIR);

if length(tfirtaps) < 128
    tfirtaps = [tfirtaps,zeros(1,128-length(tfirtaps))];
end

webinar.Fin = input.data_rate;
webinar.FIR_interp = input.FIR_interp;
webinar.HB_interp = input.HB_interp;
webinar.DAC_mult = input.DAC_mult;
webinar.PLL_mult = input.PLL_mult;
webinar.Fpass = input.Fpass;
webinar.Fstop = input.Fstop;
webinar.dBripple = input.dBripple;
webinar.dBstop = input.dBstop;
webinar.dBstop_FIR = input.dBstop_FIR;
webinar.phEQ = input.phEQ;
webinar.int_FIR = input.int_FIR;
webinar.wnom = input.wnom;
webinar.Hm1_tx = Hm1;
webinar.Hm2_tx = Hm2;
webinar.Hm3_tx = Hm3;
webinar.Hm4_tx = Hm4;
webinar.Hmd_tx = Hmd;
webinar.enable_tx = enables;

tohw.TXSAMP = input.data_rate;
tohw.TF = input.data_rate * input.FIR_interp;
tohw.T1 = tohw.TF * input.HB1;
tohw.T2 = tohw.T1 * input.HB2;
tohw.DAC = input.converter_rate;
tohw.BBPLL = input.clkPLL;
tohw.Coefficient = tfirtaps;
tohw.CoefficientSize = length(h);
tohw.Interp = input.FIR_interp;
tohw.Gain = gain;
tohw.RFBandwidth = input.RFbw;

result.tfirtaps = tfirtaps;
result.txFilters = txFilters;
result.Hanalog = Hanalog;
result.dBripple_actual = dBripple_actual;
result.dBstop_actual = dBstop_actual;
result.delay = delay;
result.webinar = webinar;
result.tohw = tohw;
result.b1 = b1;
result.a1 = a1;
result.b2 = b2;
result.a2 = a2;
