function [check1,check2,check3,check4,check5,check6] = verifyrate(Fstart,Fend,N)
step = (Fend-Fstart)/(N-1);
freq = zeros(N,1);
check1 = zeros(N,1);
check2 = zeros(N,1);
check3 = zeros(N,1);
check4 = zeros(N,1);
check5 = zeros(N,1);
check6 = zeros(N,1);
for i = 1:N
    freq(i) = round(Fstart+(i-1)*step);
    
    tohwrx = internal_designrxfilters9361_default(freq(i));
    if tohwrx.RF > 122.88e6 || tohwrx.R1 > 245.76e6 || tohwrx.R2 > 320e6 || tohwrx.ADC > 640e6
        check1(i) = 1;
    else
        check1(i) = 0;
    end
    tohwtx = internal_designtxfilters9361_default2(tohwrx);
    if tohwtx.TF > 122.88e6 || tohwtx.T1 > 160e6 || tohwtx.T2 > 320e6 || tohwtx.DAC > 320e6
        check2(i) = 1;
    else
        check2(i) = 0;
    end
    check3(i) = tohwtx.BBPLL-tohwrx.BBPLL;
         
    
    tohwtx = internal_designtxfilters9361_default(freq(i));
    if tohwtx.TF > 122.88e6 || tohwtx.T1 > 160e6 || tohwtx.T2 > 320e6 || tohwtx.DAC > 320e6
        check4(i) = 1;
    else
        check4(i) = 0;
    end
    tohwrx = internal_designrxfilters9361_default2(tohwtx);
    if tohwrx.RF > 122.88e6 || tohwrx.R1 > 245.76e6 || tohwrx.R2 > 320e6 || tohwrx.ADC > 640e6
        check5(i) = 1;
    else
        check5(i) = 0;
    end
    check6(i) = tohwtx.BBPLL-tohwrx.BBPLL;
end