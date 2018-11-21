classdef ConnectHardware < matlab.hwmgr.internal.hwsetup.ManualConfiguration
  % ConnectHardware - Screen implementation to enable users to connect
  % the PlutoSDR device to the host
  
  %   Copyright 2017-2018 The MathWorks, Inc.
  
  properties
  end
  
  methods
    function obj = ConnectHardware(varargin)
      % Call to the base class constructor
      obj@matlab.hwmgr.internal.hwsetup.ManualConfiguration(varargin{:});
      
      % Set the Title Text
      obj.Title.Text = 'Connect Hardware';%message('plutoradio:hwsetup:ConnectHardwareTitle').getString;
      
      obj.ConfigurationInstructions.Text = 'Text1';
        %message('plutoradio:hwsetup:ConnectHardware_Instruction').getString;
      obj.ConfigurationInstructions.Position = [20 280 430 85];
      
      % Increase the Height and Width of the Image before setting the
      % ImageFile
      obj.ConfigurationImage.ImageFile = fullfile(obj.Workflow.ResourceDir,...
        'adalm-pluto_connect.png');
      obj.ConfigurationImage.addHeight(80);
      obj.ConfigurationImage.addWidth(80);
      
      if isunix
        if ~ismac
          obj.ConfigurationInstructions.addWidth(15);
        end
      end
      
      % Set the HelpText
      obj.HelpText.WhatToConsider = [...
        message('plutoradio:hwsetup:ConnectHardware_WhatToConsider').getString];
      obj.HelpText.AboutSelection = '';
      obj.HelpText.Additional = '';
      
      if strcmp(obj.Workflow.FirstScreenID, class(obj))
        obj.BackButton.Visible = 'off';
        obj.BackButton.Enable = 'off';
      end

    end
    
    function restoreScreen(obj)
      obj.enableScreen();
    end
    
    function out = getPreviousScreenID(obj) %#ok<MANU>
      switch computer('arch')
        case 'win64'
          out = 'plutoradio.internal.hwsetup.InstallDriverWindows';
        case 'maci64'
          out = '';
        case 'glnxa64'
          out = 'plutoradio.internal.hwsetup.InstallDriverLinux';
      end
    end
    
    function out = getNextScreenID(obj)
      % Find the connected radio
      findRadio(obj);
      
      % Create a BusyOverlay inside the window
      busyOverlay = matlab.hwmgr.internal.hwsetup.BusyOverlay.getInstance(obj.ContentPanel);
      busyOverlay.Text = 'Checking firmware version';
      restoreOnCleanup = onCleanup(@()removeOverlay(busyOverlay));

      % Check radio firmware version
      success = isFirmwareCompatible(obj.Workflow);
      
      logMessage(obj, sprintf('isFirmwareCompatible returned %d', success));
      
      if ~success
        obj.Workflow.UpdateFirmwareWorkflow = true;
        out = 'plutoradio.internal.hwsetup.UnexpectedFirmware';
      else
        obj.Workflow.UpdateFirmwareWorkflow = false;
        out = 'plutoradio.internal.hwsetup.TestConnection';
      end
    end
  end
  
  methods (Access = private)
    function findRadio(obj)
      radios = getConnectedRadios(obj.Workflow.HardwareInterface);
      numRadios = length(radios);
      if numRadios == 0
        error(message('plutoradio:hwsetup:ConnectHardware_NoRadio').getString);
      elseif numRadios > 1
        error(message('plutoradio:hwsetup:ConnectHardware_MoreThanOneRadio').getString);
      else
        if isRadioBusy(obj.Workflow.HardwareInterface, radios.RadioID)
          error(message('plutoradio:hwsetup:ConnectHardware_RadioBusy', radios.RadioID));
        else
        setRadioID(obj.Workflow, radios.RadioID);
        setSerialNum(obj.Workflow, radios.SerialNum);
          logMessage(obj, ...
            sprintf('Found radio with ID: %s and SN: %s', ...
            radios.RadioID, radios.SerialNum));
      end
    end
  end
end
end

function removeOverlay(busyOverlay)
busyOverlay.Visible = 'off';
delete(busyOverlay)
end
