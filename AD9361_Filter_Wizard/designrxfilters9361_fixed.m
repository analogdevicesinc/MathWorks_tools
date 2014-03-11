% Inputs
% ============================================
% Fadc      = ADC sample frequecy (in Hz)
% Fout      = Output sample data rate (in Hz)
% clkPLL    = PLL clock rate (in Hz)
% Fpass     = passband frequency (in Hz)
% Fstop     = stopband frequency (in Hz)
% dBripple  = max ripple allowed in passband (in dB)
% dBstop    = min attenuation in stopband (in dB)
% dBstopmin = min rejection that RFIR is required to have (in dB)
% phEQ      = Phase Equalization on (not -1)/off (-1)
% int_FIR   = use Internal FIR (on/off)
%
% Outputs
%===============================================
% rfirtaps         = fixed point coefficients for AD9361
% rxFilters        = system object for visualization
%
function [rfirtaps,rxFilters] = designrxfilters9361_fixed(Fout,FIR_interp,HB_interp,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstopmin,phEQ,int_FIR,wnom)

[rfirtaps,rxFilters,~,~,~] = designrxfilters9361_fixed(Fout,FIR_interp,HB_interp,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstopmin,phEQ,int_FIR,wnom);