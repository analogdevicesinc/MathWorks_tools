function abc = analogresp(type,f,Fconverter,b1,a1,b2,a2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
switch type
    case 'Tx'
        abc = sinc(f/Fconverter).*freqs(b1,a1,2*pi*f).*freqs(b2,a2,2*pi*f);
    case 'Rx'
        abc = freqs(b1,a1,2*pi*f).*freqs(b2,a2,2*pi*f).*(sinc(f/Fconverter).^3);    
end

