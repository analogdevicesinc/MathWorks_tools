classdef Downloader < adi.utils.libad9361
    
    properties (Constant)
       PossibleDependencies = {'libad9361'}; 
    end
    
    methods     
        
        function download(obj,dep)
            if nargin == 0
                fprintf('Specific dependency name on input. Options are:\n%s',obj.PossibleDependencies);
            end
            switch dep
                case 'libad9361'
                    download_libad9361(obj);
                otherwise
                    error('Unknown dependency %s',dep);
            end
        end
        
    end
end

