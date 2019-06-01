classdef BSPTestsBase < matlab.unittest.TestCase
    properties(TestParameter)
        % Pull in board permutations
        configs = board_variants;
        ignored_builds = {'AnalogDevices.adrv9361z7035.ccbox_lvds.modem.plugin_board'};
        SynthesizeDesign = {false};
    end
    
    properties
        Count = 0;
        TotalTests = 0;
        Folder = pwd;
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
        function setRuntimeFolder(testCase)
            testCase.Folder = tempname(pwd);
        end
    end
    
    methods(TestClassTeardown)
        function enableWarnings(~)
            warning('on','hdlcommon:hdlcommon:InterfaceNotAssigned');
        end
        function collectLogs(~)
            if ~exist([pwd,'/logs'],'dir')
                mkdir('logs');
            end
            system('cp *.log logs/');
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
    

    
    methods
        
        function CollectLogs(testCase,cfgb)
            disp('Log collector called');
            rdn = strrep(cfgb.ReferenceDesignName,'/','_');
            rdn = strrep(rdn,'(','');
            rdn = strrep(rdn,')','');
            system(join(["find '",testCase.Folder,"' -name 'workflow_task_VivadoIPPackager.log' | xargs -I '{}' cp {} ."],''));
            if exist('workflow_task_VivadoIPPackager.log','file')
                disp('Found workflow_task_VivadoIPPackager... copying');
                movefile('workflow_task_VivadoIPPackager.log',[rdn,'_VivadoIPPackager_',cfgb.mode,'.log']);
            end
            system(join(["find '",testCase.Folder,"' -name 'workflow_task_CreateProject.log' | xargs -I '{}' cp {} ."],''));
            if exist('workflow_task_CreateProject.log','file')
                disp('Found workflow_task_CreateProject... copying');
                movefile('workflow_task_CreateProject.log',[rdn,'_CreateProject_',cfgb.mode,'.log']);
            end
            system(join(["find '",testCase.Folder,"' -name 'workflow_task_BuildFPGABitstream.log' | xargs -I '{}' cp {} ."],''));
            if exist('workflow_task_BuildFPGABitstream.log','file')
                disp('Found workflow_task_BuildFPGABitstream... copying');
                movefile('workflow_task_BuildFPGABitstream.log',[rdn,'_BuildFPGABitstream_',cfgb.mode,'.log']);
            end
        end
        
        function cfg = ADRV9361_Variants(~,s)
            
            variants = {...
                'ccbob_cmos','ccbob_lvds',...
                'ccbox_lvds','ccfmc_lvds'};
            cfg = {};
            s = strjoin(s(1:end-2),'.');
            h1 = str2func([s,'.common.plugin_board']);h1 = h1();
            
            for k = 1:length(variants)
                
                mode = 'rx';
                h2 = str2func([s,'.',variants{k},'.plugin_rd_rx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg1 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                
                mode = 'tx';
                h2 = str2func([s,'.',variants{k},'.plugin_rd_tx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg2 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                
                mode = 'rx_tx';
                h2 = str2func([s,'.',variants{k},'.plugin_rd_rxtx']);h2 = h2();
                ReferenceDesignName = h2.ReferenceDesignName;
                vivado_version = h2.SupportedToolVersion{:};
                cfg3 = struct('Board',h1,...
                    'ReferenceDesignName',ReferenceDesignName,...
                    'vivado_version',vivado_version,'mode',mode);
                cfg = [cfg(:)',{cfg1},{cfg2},{cfg3}];
                
            end
            
        end
        
        
        function cfg = extractConfigs(~,config)
            s = strsplit(config,'.');
            modes = strsplit(s{end},'_');
            mode = modes{end};
            h1 = str2func(config);h1 = h1();
            
            if strcmp(s{2},'adrv9361z7035') && ~isempty(strfind(s{2},'modem'))
                assert(0);
            elseif strcmp(s{2},'adrv9361z7035') || ...
                    strcmp(s{2},'adrv9364z7020')
                h = str2func([strjoin(s(1:2),'.'),'.common.plugin_board']);
            else
                h = str2func([strjoin(s(1:end-1),'.'),'.plugin_board']);
            end
            board = h();
            
            ReferenceDesignName = h1.ReferenceDesignName;
            vivado_version = h1.SupportedToolVersion{:};
            cfg = struct('Board',board,...
                'ReferenceDesignName',ReferenceDesignName,...
                'vivado_version',vivado_version,'mode',mode);
        end
        
        function setVivadoPath(~,vivado)
            if ispc
                pathname = ['C:\Xilinx\Vivado\',vivado,'\bin\vivado.bat'];
            elseif isunix
                pathname = ['/opt/Xilinx/Vivado/',vivado,'/bin/vivado'];
            end
            assert(exist(pathname,'file')>0,'Correct version of Vivado is unavailable or in a non-standard location');
            hdlsetuptoolpath('ToolName', 'Xilinx Vivado', ...
                'ToolPath', pathname);
            pause(4);
        end
    end
    
    methods(Test)
        function testMain(testCase, configs, SynthesizeDesign)
            % Filter out ignored configurations
            if ismember(configs,testCase.ignored_builds)
                assumeFail(testCase);
            end
            % Extract board configuration
            cfgb = testCase.extractConfigs(configs);
            %             for cfg = cfgs
            if exist(testCase.Folder,'dir')
                rmdir(testCase.Folder,'s');
                pause(1);
            end
            % Set up vivado
            testCase.setVivadoPath(cfgb.vivado_version);
            % Build
            disp(repmat('/',1,80));
            disp(['Building: ',cfgb.Board.BoardName,' | ',cfgb.mode,...
                ' (',num2str(testCase.Count),' of ',num2str(testCase.TotalTests),')']);
            res = build_design(cfgb.Board,cfgb.ReferenceDesignName,...
                cfgb.vivado_version,cfgb.mode,cfgb.Board.BoardName,...
                SynthesizeDesign,testCase.Folder);
            % Check
            if isfield(res,'message') || isa(res,'MException')
                disp(['Build error: ', cfgb.ReferenceDesignName]);
                disp(res);
                disp(res.message);
                disp(res.stack);
                testCase.CollectLogs(cfgb);
                verifyEmpty(testCase,res,res.message);
            end
        end
    end
end
