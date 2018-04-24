function [found, out] = PacketDetector(in, preamble)

taps = preamble(end:-1:1);

pLen = length(preamble);
inDelayed = zeros(pLen,1);
inBufferSQ = zeros(pLen,1);
inBuffer = zeros(pLen,1);
onesRow = ones(1,pLen);
out = zeros(length(in),1);

found = false;

for i=1:length(in)
    
    inBuffer = [in(i); inBuffer(1:end-1)];
    inBufferSQ = [abs(in(i))^2; inBufferSQ(1:end-1)];
    if i>pLen
        inDelayed = [in(i-pLen); inDelayed(1:end-1)];        
    end
    squared = inBuffer.*inDelayed;
    
    sig = onesRow*squared;
    energy = onesRow*inBufferSQ;
    
    out(i) = abs(sig/energy);
    
    if out(i)>0.65 % Numerically found
       found = true;
       fprintf('Packet found\n');
       return
    end
    
end
fprintf('Packet not found\n');
stem(out);

end