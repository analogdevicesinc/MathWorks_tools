classdef BSPTests < matlab.unittest.TestCase
    properties(TestParameter)
        % Pull in board permutations
        configs = hdlcoder_board_customization;
    end
    
    methods(Static)
        function cfg = extractConfigs(config)
            s = strsplit(config,'.');mode = s{4};
            if strcmp(s{2},'RFSOM1')
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
    end
    
    methods(Test)
        function testMain(testCase, configs)
            % Extract board configuration
            cfg = testCase.extractConfigs(configs);
            % Build
            res = build_design(cfg.Board,cfg.ReferenceDesignName,...
                cfg.vivado_version,cfg.mode);
            % Check
            testCase.assertEmpty(res,res);
            
        end
    end
end