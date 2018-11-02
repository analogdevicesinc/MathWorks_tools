fullFrameFilt = generateBadFrame('StartPadding',2^4);
BBW = comm.BasebandFileWriter('CRCErrorData.bb',1000000,2.4e9);
BBW(int16(2^15.*fullFrameFilt));