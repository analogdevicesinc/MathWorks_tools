fm5 = adi.FMComms5.Rx;
fm5.uri = 'ip:192.168.3.2';
fm5.channelCount = 8;
[a,b,c,d] = fm5();
plot(real([a,b,c,d]));