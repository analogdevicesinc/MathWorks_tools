classdef Step1 < adi.StepBase
    
    %   Copyright 2017 The MathWorks, Inc.
    properties (Hidden)
       InstallButton 
    end
    
    methods
        function obj = Step1(varargin)
            obj@adi.StepBase(varargin{:});
            
            %       obj.Workflow.InstallDriverWorkflow = true;
            
            parentContainer = obj.ContentPanel;
            
            obj.Title.Text = 'ADI Board Support Package Installer';
            
            obj.InfoText1.Position = [20 340 400 30];
            obj.InfoText1.Text = 'Step 1: Installing drivers';
            
            obj.InfoText2.Position = [20 290 400 50];
            obj.InfoText2.Text = 'Test2';
            
            obj.InstallButton = matlab.hwmgr.internal.hwsetup.Button.getInstance(parentContainer);
            obj.InstallButton.ButtonPushedFcn = @obj.LinuxInstall;
            obj.InstallButton.Text = 'WINNER';
            
            obj.HelpText.AboutSelection = 'About Selection';
            obj.HelpText.WhatToConsider = 'Test3';
        end
        
        function out = getNextScreenID(obj)
            % HSA infrastructure requires a "getNextScreenID" method implemented
            % in the leaf class. Otherwise, it renders "Finish" button instead of
            % "Next".
            out = getNextScreenIDImpl(obj);
        end
        
        function restoreScreen(obj)
            obj.enableScreen();
        end
    end

    methods (Access = protected)
        
        function out = getNextScreenIDImpl(~)
            out = 'adi.Step2';
        end
        
        function LinuxInstall(~,~,~)
            system('sudo whoami');
        end
        
    end
    
end
