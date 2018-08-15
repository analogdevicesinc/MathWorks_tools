classdef BSPTests < matlab.unittest.TestCase
    properties(TestParameter)
        % Pull in board permutations
        configs = hdlcoder_board_customization_local;
        ignored_builds = {'AnalogDevices.adrv9361z7035.ccbox_lvds.modem.plugin_board'};
    end    
    
    methods(TestClassSetup)
        % Add the necessary files to path
        function addbspfiles(~)
            addpath(genpath('../hdl_wa_bsp'));
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
            h2 = str2func([s,'.plugin_rd']);h2 = h2();
            ReferenceDesignName = h2.ReferenceDesignName;
            vivado_version = h2.SupportedToolVersion{:};
            cfg = struct('Board',h1,...
                'ReferenceDesignName',ReferenceDesignName,...
                'vivado_version',vivado_version,'mode',mode);
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
        function testMain(testCase, configs)
            % Filter out ignored configurations
            if ismember(configs,testCase.ignored_builds)
                assumeFail(testCase);
            end
            if exist([pwd,'/hdl_prj'],'dir')
                rmdir('hdl_prj','s');
            end
            % Extract board configuration
            cfg = testCase.extractConfigs(configs);
            % Set up vivado
            testCase.setVivadoPath(cfg.vivado_version);
            % Build
            disp(['Building: ',cfg.Board.BoardName]);
            res = build_design(cfg.Board,cfg.ReferenceDesignName,...
                cfg.vivado_version,cfg.mode);
            % Check
            if isfield(res,'message')
                verifyEmpty(testCase,res,res.message);
            end
        end
    end
end
