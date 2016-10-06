function extmodeHooksADI(hObj,hookpoint)

% Copyright 2014-2015 The MathWorks, Inc.

modelName = get(getModel(hObj),'Name');
modelName = sprintf('%s.elf', modelName);
data = codertarget.data.getData(hObj);
h__z = zynq(data.RTOS);
h__z.IPAddress = getenv('ADI_ZYNQ_SDR_IPADDRESS');
h__z.Username = 'root';
h__z.Password = 'analog';

switch (lower(hookpoint))
    case 'preconnectfcn',
        waitForAppToStart(h__z, modelName, 60);
    case 'setupfcn'
        checkConnection(h__z);
    otherwise
end

end
