dev = sdrdev('ZynqRadioLibIIO');

downloadImage(dev,'BoardName', 'ADI RF SOM', ...
     'FPGAImage', 'system_top.bit');