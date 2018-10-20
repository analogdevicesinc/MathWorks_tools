classdef InstallDriverBase < matlab.hwmgr.internal.hwsetup.TemplateBase

%   Copyright 2017 The MathWorks, Inc.

  properties
    InfoText1
    InfoText2
    InfoText3
  end
  
  methods
    function obj = InstallDriverBase(varargin)
      obj@matlab.hwmgr.internal.hwsetup.TemplateBase(varargin{:});
      
      obj.Workflow.InstallDriverWorkflow = true;
      
      parentContainer = obj.ContentPanel;

      obj.InfoText1 = matlab.hwmgr.internal.hwsetup.Label.getInstance(parentContainer);
      obj.InfoText1.Position = [20 290 400 80];
      obj.InfoText1.Text = '';
      obj.InfoText1.Color = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;

      obj.InfoText2 = matlab.hwmgr.internal.hwsetup.Label.getInstance(parentContainer);
      obj.InfoText2.Position = [20 230 400 50];
      obj.InfoText2.Text = '';
      obj.InfoText2.Color = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
      
      obj.InfoText3 = matlab.hwmgr.internal.hwsetup.Label.getInstance(parentContainer);
      obj.InfoText3.Position = [20 170 400 50];
      obj.InfoText3.Text = '';
      obj.InfoText3.Color = matlab.hwmgr.internal.hwsetup.util.Color.WHITE;
      
      obj.HelpText.AboutSelection = '';
      obj.HelpText.WhatToConsider = '';

      if strcmp(obj.Workflow.FirstScreenID, class(obj))
        obj.BackButton.Visible = 'off';
        obj.BackButton.Enable = 'off';
      end
    end
    
    function restoreScreen(obj)
      obj.enableScreen();
    end
  end
  
  methods (Access = protected, Abstract)
    status = installDriverImpl(obj)
  end
  
  methods (Access = protected)
    function installDriver(obj)
      obj.disableScreen();
      restoreOnCleanup = onCleanup(@obj.restoreScreen);

      p = matlab.hwmgr.internal.hwsetup.Panel.getInstance(obj.ContentPanel);
      p.Title = '';
      b = matlab.hwmgr.internal.hwsetup.BusyOverlay.getInstance(p);
      b.Text = 'Installing USB driver...';
      b.show();
      deleteOverlayOnCleanup = onCleanup(@()delete(p));

      [status,msg] = installDriverImpl(obj);

      if status
        error(message('plutoradio:hwsetup:DriverInstallFailed', msg));
      end
      
      refocus(obj.Workflow);
    end
    
    function out = getNextScreenIDImpl(obj)
      out = 'adi.ConnectHardware';
      installDriver(obj);
    end
  end
end
