classdef ADIWorkFlow < matlab.hwmgr.internal.hwsetup.Workflow
  
  properties(Constant)
    % Properties inherited from Workflow class
    BaseCode = 'ADIBSP';
  end
  
  properties
    % Properties inherited from Workflow class
    Name = 'Hardware Setup App for Analog Devices Board Support Packages'
    FirstScreenID
    ResourceDir
    ShowExamples = true;
    InstalledUdevRule
    DriverInstalled
    CompilerConfigured
    InstallDriverWorkflow = false
    ExpectedFirmwareVersion = ''
    CurrentFirmwareVersion = ''
    UpdateFirmwareWorkflow = false
    UpdateFirmwareSelected = true
    HardwareInterface
    Testing = false
  end
  
  methods
    % Class Constructor
    function obj = ADIWorkFlow(varargin)
      obj@matlab.hwmgr.internal.hwsetup.Workflow(varargin{:})
      
%       obj.HardwareInterface = plutoradio.internal.hwsetup.HardwareInterface;

%       obj.DriverInstalled = ...
%         matlab.hwmgr.internal.hwsetup.register.PlutoRadioWorkFlow.checkDriver();

      determineFirstScreen(obj);
      
%       obj.ResourceDir = fullfile(plutoradio.internal.getRootDir, 'resources');
      
      % Setup MATLAB session for PlutoSDR HSP
%       dev = sdrdev('Pluto');
      
      % Consider saving path, etc.
      
    end
    
    function determineFirstScreen(obj)
%       arch = computer('arch');
%       if (obj.DriverInstalled || strcmp(arch, 'maci64'))
%         firstScreen = 'plutoradio.internal.hwsetup.ConnectHardware';
%       else
%         switch arch
%           case 'win64'
%             firstScreen = 'plutoradio.internal.hwsetup.InstallDriverWindows';
%           case 'glnxa64'
%             firstScreen = 'plutoradio.internal.hwsetup.InstallDriverLinux';
%         end
%       end

% firstScreen = 'adi.InstallDriverLinux';
      
      firstScreen = 'adi.Step1';
      obj.FirstScreenID = firstScreen;
    end
    
    function refocus(obj)
      f = findall(0, 'type', 'figure', 'Name', 'Hardware Setup');
      idx = strfind(obj.FirstScreenID, '.');
      tag = strrep(obj.FirstScreenID(1:idx(end)), '.', '_');
      for p=1:length(f)
        if contains(f(p).Tag, tag)
          pause(3);
          figure(f(1));
        end
      end
    end
    
    function success = isFirmwareCompatible(obj)
      success = false;
      
      [expVer,curVer] = getFirmwareVersion(obj.HardwareInterface);
      if isempty(curVer)
        errordlg(obj, ...
          message('plutoradio:hwsetup:UpdateFirmware_USBSearchFailed', '').getString);
      else
        obj.CurrentFirmwareVersion = curVer;
        obj.ExpectedFirmwareVersion = expVer;
        if expVer == curVer
          success = true;
        end
      end
    end
    
    function setSerialNum(obj, serialNum)
      obj.HardwareInterface.SerialNum = serialNum;
    end
    
    function serialNum = getSerialNum(obj)
      serialNum = obj.HardwareInterface.SerialNum;
    end
    
    function setRadioID(obj, radioID)
      obj.HardwareInterface.RadioID = radioID;
    end
    
    function radioID = getRadioID(obj)
      radioID = obj.HardwareInterface.RadioID;
    end
    
    function varargout = warndlg(~, msg)
      dlgHandle = warndlg(msg, ...
        message('plutoradio:hwsetup:UpdateFirmware_Title').getString);
      if nargout > 0
        varargout{1} = dlgHandle;
      end
    end
    
    function varargout = errordlg(~, msg)
      dlgHandle = errordlg(msg, ...
        message('plutoradio:hwsetup:UpdateFirmware_Title').getString);
      if nargout > 0
        varargout{1} = dlgHandle;
      end
    end
  end
  
  methods (Static)
    function flag = checkDriver()
      % Assume driver is installed
      flag = true;
      
      switch computer('arch')
        case 'win64'
          try
            installPath = winqueryreg(...
              'HKEY_LOCAL_MACHINE',...
              'SOFTWARE\Analog Devices\PlutoSDR-M2k-USB-Win-Drivers\Settings',...
              'InstallPath'); %#ok<NASGU>
          catch me
            if strcmp(me.identifier, 'MATLAB:WINQUERYREG:invalidkey')
              flag = false;
            end
          end
        case 'glnxa64'
          udevFileName = '90-plutosdr-mw.rules';
          udevFile = fullfile('/lib/udev/rules.d', udevFileName);
          if ~exist(udevFile, 'file')
            flag = false;
          else
            % Check the content
            expectedContent = sprintf('%s\n%s\n', ...
              '# PlutoSDR', ...
              ['SUBSYSTEMS=="usb", ATTRS{idVendor}=="0456", '...
              'ATTRS{idProduct}=="b673", MODE:="0666"']);
            fid = fopen(udevFile, 'r');
            fileContent = fscanf(fid, '%s', inf);
            fclose(fid);
            if ~strcmp(replace(expectedContent, {' ', newline}, ''), fileContent)
              flag = false;
            end
          end
        case 'maci64'
          rootDir = plutoradio.internal.getRootDir;
          command = sprintf('%s/bin/maci64/iio_info -s | grep Analog', rootDir);
          [status, out] = system(command);
          if status || ~contains(out, 'Analog Devices Inc. PlutoSDR (ADALM-PLUTO)')
            flag = false;
          end
      end
    end
  end
end
