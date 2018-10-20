classdef InstallDriverLinux < adi.InstallDriverBase

%   Copyright 2017 The MathWorks, Inc.

  methods
    function obj = InstallDriverLinux(varargin)
      obj@adi.InstallDriverBase(varargin{:});

      obj.Title.Text = 'ADI Board Support Package Installer';
      
      obj.InfoText1.Position = [20 340 400 30];
      obj.InfoText1.Text = 'Test1';%message('plutoradio:hwsetup:InstallDriverLinux_InfoText1').getString;

      obj.InfoText2.Position = [20 290 400 50];
      obj.InfoText2.Text = 'Test2';%message('plutoradio:hwsetup:InstallDriverLinux_InfoText2').getString;
      
      obj.HelpText.AboutSelection = '';
      obj.HelpText.WhatToConsider = 'Test3';%message('plutoradio:hwsetup:InstallDriverLinux_WhatToConsider').getString;
    end
    
    function out = getNextScreenID(obj)
      % HSA infrastructure requires a "getNextScreenID" method implemented
      % in the leaf class. Otherwise, it renders "Finish" button instead of
      % "Next".
      out = getNextScreenIDImpl(obj);
    end
  end
  
  methods (Access = protected)
    function [status,out] = installDriverImpl(obj)
      udevFileName = '90-plutosdr-mw.rules';
      udevrules = fullfile(tempdir, udevFileName);
      fid = fopen(udevrules, 'wt');
      fprintf(fid, '%s\n%s\n', ...
        '# PlutoSDR', ...
        ['SUBSYSTEMS=="usb", ATTRS{idVendor}=="0456", '...
        'ATTRS{idProduct}=="b673", MODE:="0666"']);
      fclose(fid);

      commandwindow
      [status,out] = run(obj.Workflow.HardwareInterface, 'sudo echo', '-echo');
      
      if ~status
        [status,out] = run(obj.Workflow.HardwareInterface, ['sudo cp ' udevrules ' /lib/udev/rules.d']);
        if ~status
          [status,out] = run(obj.Workflow.HardwareInterface, 'sudo udevadm control --reload');
          if ~status
            [status,out] = run(obj.Workflow.HardwareInterface, 'sudo udevadm trigger');
          end
        end
      end
      run(obj.Workflow.HardwareInterface, sprintf('rm %s', udevrules));
      
      if ~status
        obj.Workflow.InstalledUdevRule = ...
          fullfile('/lib/udev/rules.d', udevFileName);
      end
    end
  end
end