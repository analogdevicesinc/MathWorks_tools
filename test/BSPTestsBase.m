classdef BSPTestsBase < matlab.unittest.TestCase
    properties(TestParameter)
        % Pull in board permutations
        configs = hdlcoder_board_customization_local;
        ignored_builds = {'AnalogDevices.adrv9361z7035.ccbox_lvds.modem.plugin_board'};
        SynthesizeDesign = {false};
    end
    
    properties
        Count = 0;
        TotalTests = 0;
    end
    
    methods(TestClassSetup)
        function disableWarnings(~)
            warning('off','hdlcommon:hdlcommon:InterfaceNotAssigned');
        end
        function testCount(testCase)
            testCase.TotalTests = length(testCase.configs);
            CountS = 0;
            save('tc.mat','CountS');
        end
    end
    
    methods(TestClassTeardown)
        function enableWarnings(~)
            warning('on','hdlcommon:hdlcommon:InterfaceNotAssigned');
        end
        function collectLogs(~)
            if ~exist([pwd,'../logs'],'dir')
                mkdir('../logs','s');
            end
            system('cp *.log ../logs');
        end
    end
    
    methods(TestMethodSetup)
        function loadTestCount(testCase)
            l = load('tc.mat');
            CountS = l.CountS + 1;
            testCase.Count = CountS;
            save('tc.mat','CountS');
        end
    end
    
    methods(Static)
        
        function cfg = extractConfigs(config)
            s = strsplit(config,'.');mode = s{4};
            if strcmp(s{2},'adrv9361z7035') && ~isempty(strfind(s{2},'modem'))
                assert(0);
            end
            s = strjoin(s(1:end-1),'.');
            h1 = str2func([s,'.plugin_board']);h1 = h1();
            try
                h2 = str2func([s,'.plugin_rd']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                cfg = {cfg};
                return
            catch
                mode = 'rx';
                h2 = str2func([s,'.plugin_rd_rx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg1 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                
                mode = 'tx';
                h2 = str2func([s,'.plugin_rd_tx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg2 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                
                mode = 'rx_tx';
                h2 = str2func([s,'.plugin_rd_rxtx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg3 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                cfg = {cfg1,cfg2,cfg3};
            end
        end
        
        function setVivadoPath(vivado)
            if ispc
                pathname = ['C:\Xilinx\Vivado\',vivado,'\bin\vivado.bat'];
            elseif isunix
                pathname = ['/opt/Xilinx/Vivado/',vivado,'/bin/vivado'];
            end
            assert(exist(pathname,'file')>0,'Correct version of Vivado is unavailable or in a non-standard location');
            hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
                'ToolPath', pathname);
        end
    end
    
    methods(Test)
        function testMain(testCase, configs, SynthesizeDesign)
            % Filter out ignored configurations
            if ismember(configs,testCase.ignored_builds)
                assumeFail(testCase);
            end
            % Extract board configuration
            cfgs = testCase.extractConfigs(configs);
            for cfg = cfgs
                if exist([pwd,'/hdl_prj'],'dir')
                    rmdir('hdl_prj','s');
                end
                cfgb = cfg{:};
                % Set up vivado
                testCase.setVivadoPath(cfgb.vivado_version);
                % Build
                disp(repmat('/',1,80));
                disp(['Building: ',cfgb.Board.BoardName,' | ',cfgb.mode,...
                    ' (',num2str(testCase.Count),' of ',num2str(testCase.TotalTests),')']);
                res = build_design(cfgb.Board,cfgb.ReferenceDesignName,...
                    cfgb.vivado_version,cfgb.mode,cfgb.Board.BoardName,...
                    SynthesizeDesign);
                % Check
                if isfield(res,'message') || isa(res,'MException')
                    disp(['Build error: ', cfgb.ReferenceDesignName]);
                    disp(res);
                    disp(res.message);
                    disp(res.stack);
                    system("find hdl_prj/ -name 'workflow_task_CreateProject.log' | xargs -I '{}' cp {} .");
                    if exist('workflow_task_CreateProject.log','file')
                       movefile('workflow_task_CreateProject.log',[cfgb.ReferenceDesignName,'_CreateProject_',cfgb.mode,'.log']);
                    end
                    system("find hdl_prj/ -name 'workflow_task_BuildFPGABitstream.log' | xargs -I '{}' cp {} .");
                    if exist('workflow_task_BuildFPGABitstream.log','file')
                       movefile('workflow_task_BuildFPGABitstream.log',[cfgb.ReferenceDesignName,'_BuildFPGABitstream_',cfgb.mode,'.log']);
                    end
                    verifyEmpty(testCase,res,res.message);
                end
            end
        end
    end
end
