% Inputs
% ============================================
% Fdac      = DAC sample frequecy (in Hz)
% Fin       = Input sample data rate (in Hz)
% clkPLL    = PLL clock rate (in Hz)
% Fpass     = passband frequency (in Hz)
% Fstop     = stopband frequency (in Hz)
% dBripple  = max ripple allowed in passband (in dB)
% dBstop    = min attenuation in stopband (in dB)
% dBstopmin = min rejection that TFIR is required to have (in dB)
% phEQ      = Phase Equalization on (not -1)/off (-1)
%
% Outputs
%===============================================
% tfirtaps         = fixed point coefficients for AD9361
% txFilters        = system object for visualization
%
function [tfirtaps,txFilters] = designtxfilters9361_fixed(Fin,FIR_interp,HB_interp,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstopmin,phEQ,int_FIR, wnom)

[tfirtaps,txFilters,~,~,~] = internal_designtxfilters9361_fixed(Fin,FIR_interp,HB_interp,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstopmin,phEQ,int_FIR, wnom);