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
%
function [Fdata,FIR_interp,HB_interp,DAC_mult,PLL_mult,FIR_decim,HB_decim,PLL_multr] = settxrxclock(Fdata)

MAX_BBPLL_FREQ = 1430000000;                         % 1430.0 MHz
MIN_BBPLL_FREQ =  715000000;                         %  715.0 MHz

MAX_ADC_CLK    =  640000000;                         %  640.0 MHz
MIN_ADC_CLK    =  MIN_BBPLL_FREQ / (2 ^ 6);  %   11.2 MHz
MAX_DAC_CLK    =  MAX_ADC_CLK / 2;           % (MAX_ADC_CLK / 2)

MAX_DATA_RATE  =   61440000;                         %   61.44 MSPS
MIN_DATA_RATE  =  MIN_BBPLL_FREQ / (48 * (2 ^ 6));

if Fdata > MAX_DATA_RATE
    Fdata = MAX_DATA_RATE;
elseif Fdata < MIN_DATA_RATE
    Fdata = MIN_DATA_RATE;
end

DAC_mult = 2;
HBandFIR_tmp = [1 2 3 4 6 8 12 16 24 32 48];
PLL_tmp = [2 4 8 16 32 64];

% TX
if Fdata * HBandFIR_tmp(end) < MAX_DAC_CLK
    HBandFIR = HBandFIR_tmp(end);
    Fdac = Fdata * HBandFIR;
else
    for i = 1:length(HBandFIR_tmp)
        if Fdata * HBandFIR_tmp(i) > MAX_DAC_CLK
            HBandFIR = HBandFIR_tmp(i-1);
            Fdac = Fdata * HBandFIR;
            break;
        end
    end
end

if Fdac * DAC_mult > MAX_BBPLL_FREQ
    DAC_mult = 1;
    PLL_mult = 2;
    HBandFIR = HBandFIR/2;
elseif Fdac * DAC_mult * PLL_tmp(1) > MAX_BBPLL_FREQ
    PLL_mult = 2;
    HBandFIR = HBandFIR/2;
elseif Fdac * 2 * 64 <= MAX_BBPLL_FREQ % handle minimum case
    DAC_mult = 1;
    PLL_mult = 64;
else
    for j = 1:length(PLL_tmp)
        if Fdac * DAC_mult * PLL_tmp(j) > MAX_BBPLL_FREQ
            break;
        else
            PLL_mult = PLL_tmp(j);
        end
    end
end

switch HBandFIR
    case 1
        FIR_interp = 1;
        HB_interp = 1;
    case 2
        FIR_interp = 1;
        HB_interp = 2;
    case 3
        FIR_interp = 1;
        HB_interp = 3;
    case 4
        FIR_interp = 2;
        HB_interp = 2;
    case 6
        FIR_interp = 2;
        HB_interp = 3;
    case 8
        FIR_interp = 2;
        HB_interp = 4;
    case 12
        FIR_interp = 2;
        HB_interp = 6;
    case 16
        FIR_interp = 2;
        HB_interp = 8;
    case 24
        FIR_interp = 2;
        HB_interp = 12;
    case 32
        FIR_interp = 4;
        HB_interp = 8;
    case 48
        FIR_interp = 4;
        HB_interp = 12;
end

Fdac = Fdata * FIR_interp * HB_interp;
clkPLLt = Fdac * DAC_mult * PLL_mult;

% RX
if Fdata * HBandFIR_tmp(end) < MAX_ADC_CLK
    HBandFIRr = HBandFIR_tmp(end);
    Fadc = Fdata * HBandFIRr;
else
    for i = 1:length(HBandFIR_tmp)
        if Fdata * HBandFIR_tmp(i) > MAX_ADC_CLK
            HBandFIRr = HBandFIR_tmp(i-1);
            Fadc = Fdata * HBandFIRr;
            break;
        end
    end
end

if Fadc * PLL_tmp(1) > MAX_BBPLL_FREQ
    PLL_multr = 2;
    HBandFIRr = HBandFIRr/2;
else
    for j = 1:length(PLL_tmp)
        if Fadc * PLL_tmp(j) > MAX_BBPLL_FREQ
            break;
        else
            PLL_multr = PLL_tmp(j);
        end
    end
end

switch HBandFIRr
    case 1
        FIR_decim = 1;
        HB_decim = 1;
    case 2
        FIR_decim = 1;
        HB_decim = 2;
    case 3
        FIR_decim = 1;
        HB_decim = 3;
    case 4
        FIR_decim = 2;
        HB_decim = 2;
    case 6
        FIR_decim = 2;
        HB_decim = 3;
    case 8
        FIR_decim = 2;
        HB_decim = 4;
    case 12
        FIR_decim = 2;
        HB_decim = 6;
    case 16
        FIR_decim = 2;
        HB_decim = 8;
    case 24
        FIR_decim = 2;
        HB_decim = 12;
    case 32
        FIR_decim = 4;
        HB_decim = 8;
    case 48
        FIR_decim = 4;
        HB_decim = 12;
end

Fadc = Fdata * FIR_decim * HB_decim;
clkPLLr = Fadc * PLL_multr;

tminusr = clkPLLt-clkPLLr;

if tminusr == 0
    return;
elseif tminusr > 0 && rem(HB_decim,3)== 0 % clkPLLt > clkPLLr
    HB_decim = 2/3*HB_decim;
    PLL_multr = 2*PLL_multr;
elseif tminusr < 0 && clkPLLt/clkPLLr == 2/3 % clkPLLt < clkPLLr
    HB_decim = 2/3*HB_decim;
end