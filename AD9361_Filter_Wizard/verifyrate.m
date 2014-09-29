clear
clc
%% Verify the data rate on Tx path by default
for i = 1:9
    freq(i)=(i+1)*1e5;
    tohwtx = internal_designtxfilters9361_default(freq(i));
    if tohwtx.TF > 122.88e6 || tohwtx.T1 > 160e6 || tohwtx.T2 > 320e6 || tohwtx.DAC > 320e6
        check1(i) = 1;
    else
        check1(i) = 0;
    end
end

%% Verify the data rate on Rx path by default
for i = 1:9
    freq(i)=(i+1)*1e5;
    tohwrx = internal_designrxfilters9361_default(freq(i));
    if tohwrx.RF > 122.88e6 || tohwrx.R1 > 245.76e6 || tohwrx.R2 > 320e6 || tohwrx.ADC > 640e6
        check2(i) = 1;
    else
        check2(i) = 0;
    end
end

%% Verify the data rate on Tx path by default2
for i = 1:9
    freq(i)=(i+1)*1e5;
    tohwrx = internal_designrxfilters9361_default(freq(i));
    tohwtx = internal_designtxfilters9361_default2(tohwrx);
    if tohwtx.TF > 122.88e6 || tohwtx.T1 > 160e6 || tohwtx.T2 > 320e6 || tohwtx.DAC > 320e6
        check3(i) = 1;
    else
        check3(i) = 0;
    end
end

%% Verify the data rate on Rx path by default2
for i = 1:9
    freq(i)=(i+1)*1e5;
    tohwtx = internal_designtxfilters9361_default(freq(i));
    tohwrx = internal_designrxfilters9361_default2(tohwtx);
    if tohwrx.RF > 122.88e6 || tohwrx.R1 > 245.76e6 || tohwrx.R2 > 320e6 || tohwrx.ADC > 640e6
        check4(i) = 1;
    else
        check4(i) = 0;
    end
end