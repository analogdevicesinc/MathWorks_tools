% Inputs
% ============================================
% Fin        = Input sample data rate (in Hz)
% FIR_interp = FIR interpolation factor
% HB_interp  = half band filters interpolation factor
% DAC_mult   = ADC to DAC ratio
% PLL_mult   = PLL multiplication
% Fpass      = passband frequency (in Hz)
% Fstop      = stopband frequency (in Hz)
% dBripple   = max ripple allowed in passband (in dB)
% dBstop     = min attenuation in stopband (in dB)
% dBstop_FIR = min rejection that TFIR is required to have (in dB)
% phEQ       = Phase Equalization on (not -1)/off (-1)
% int_FIR    = Use AD9361 FIR on (1)/off (0)
% wnom       = analog cutoff frequency (in Hz)
%
% Outputs
%===============================================
% tfirtaps         = fixed point coefficients for AD9361
% txFilters        = system object for visualization
%
function [tfirtaps,txFilters] = designtxfilters9361(Fin,FIR_interp,HB_interp,DAC_mult,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstop_FIR,phEQ,int_FIR, wnom)

[tfirtaps,txFilters,~,~,~,~,~,~,~,~,~,~] = internal_designtxfilters9361_sinc(Fin,FIR_interp,HB_interp,DAC_mult,PLL_mult,Fpass,Fstop,dBripple,dBstop,dBstop_FIR,phEQ,int_FIR, wnom);
