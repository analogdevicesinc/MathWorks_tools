
v=ver('matlab'); Release = v.Release;
switch Release
    case '(R2017a)'
        vivado = '2016.2';
    case '(R2017b)'
        vivado = '2016.4';
end

if ispc
    hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
        'ToolPath', ['C:\Xilinx\Vivado\',vivado,'\bin\vivado.bat']);
elseif isunix
    hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
        'ToolPath', ['/opt/Xilinx/Vivado/',vivado,'/bin/vivado']);
end
