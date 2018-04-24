rx = sdrrx('ADI RF SOM');
rx.BasebandSampleRate = 3840000;
rx.BypassUserLogic = false;

for x=1:1e3
   d = rx(); 
   fcn(real(d),imag(d));
end



function fcn(startLen, data)

persistent framebuffer counter mode pCounter

PacketLength = 13;

if isempty(framebuffer)
    framebuffer = int16(zeros(1,100));
    counter = int16(0);
    pCounter = uint64(0);
    mode = uint8(0);
end

%data(data<0) = 0;

%disp(char(data).');
for k=1:length(startLen)
    
    switch mode
        case uint8(0)
            if startLen(k) % Start called
                counter = int16(2);
                if data(k)>0 && data(k)<256
                framebuffer(1) = data(k);
                end
                mode = uint8(1);
            end
        case uint8(1)
            if data(k)>0 && data(k)<256
                framebuffer(counter) = data(k);
            end
            if counter == PacketLength
                pCounter = pCounter + uint64(1);
                if sum(framebuffer)==26 % Skip startup buffers
                    continue;
                end
                fprintf("%s\n",char(framebuffer(1:PacketLength)));
                mode = uint8(0);
            else
                counter = counter + int16(1);
            end
    end
    
end
end