function setportmapping(mdl,mode,numChannels)

if mod(numChannels,2)~=0
    error('Channels must be multiple of 2');
end

% First set all ports to NIS
for k=1:8
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/in',num2str(k)], 'IOInterfaceMapping', '');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterface', 'No Interface Specified');
    hdlset_param([mdl,'/HDL_DUT/out',num2str(k)], 'IOInterfaceMapping', '');
end

        
switch mode
    case 'tx'
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', 'IP Data 0 IN [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', 'IP Data 1 IN [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', 'AD9361 DAC Data I0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', 'AD9361 DAC Data Q0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', '[0:15]');
        if numChannels==4
            hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', 'IP Data 2 IN [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', 'IP Data 3 IN [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', 'AD9361 DAC Data I1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', 'AD9361 DAC Data Q1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', '[0:15]');
        end
    case 'rx'
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', 'AD9361 ADC Data I0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', 'AD9361 ADC Data Q0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', 'IP Data 0 OUT [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', 'IP Data 1 OUT [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', '[0:15]');
        if numChannels==4
            hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', 'AD9361 ADC Data I1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', 'AD9361 ADC Data Q1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', 'IP Data 2 OUT [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', 'IP Data 3 OUT [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', '[0:15]');
        end
    case 'rx_tx'
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterface', 'AD9361 ADC Data I0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterface', 'AD9361 ADC Data Q0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in2'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterface', 'IP Data 0 OUT [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out1'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterface', 'IP Data 1 OUT [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out2'], 'IOInterfaceMapping', '[0:15]');
        
        hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterface', 'IP Data 0 IN [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in3'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterface', 'IP Data 1 IN [0:15]');
        hdlset_param([mdl,'/HDL_DUT/in4'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterface', 'AD9361 DAC Data I0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out3'], 'IOInterfaceMapping', '[0:15]');
        hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterface', 'AD9361 DAC Data Q0 [0:15]');
        hdlset_param([mdl,'/HDL_DUT/out4'], 'IOInterfaceMapping', '[0:15]');
        
        
        if numChannels==4
            hdlset_param([mdl,'/HDL_DUT/in5'], 'IOInterface', 'IP Data 2 IN [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in5'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/in6'], 'IOInterface', 'IP Data 3 IN [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in6'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out5'], 'IOInterface', 'AD9361 DAC Data I1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out5'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out6'], 'IOInterface', 'AD9361 DAC Data Q1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out6'], 'IOInterfaceMapping', '[0:15]');
            
            hdlset_param([mdl,'/HDL_DUT/in7'], 'IOInterface', 'AD9361 ADC Data I1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in7'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/in8'], 'IOInterface', 'AD9361 ADC Data Q1 [0:15]');
            hdlset_param([mdl,'/HDL_DUT/in8'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out7'], 'IOInterface', 'IP Data 2 OUT [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out7'], 'IOInterfaceMapping', '[0:15]');
            hdlset_param([mdl,'/HDL_DUT/out8'], 'IOInterface', 'IP Data 3 OUT [0:15]');
            hdlset_param([mdl,'/HDL_DUT/out8'], 'IOInterfaceMapping', '[0:15]');
        end
        
    otherwise
        error('Unknown mode');
end
