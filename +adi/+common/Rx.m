classdef (Abstract) Rx  < adi.common.RxTx
    % Rx: Common shared functions between receiver classes
    properties(Constant, Hidden, Logical)
        EnableCyclicBuffers = false;
    end
    methods (Hidden, Access = protected)
        
        function varargout = stepImpl(obj)
            % Get the data
            c = obj.channelCount/2;
            if c > 0
                [dataRAW, valid] = getData(obj);
                index = 1;
                varargout = cell(c+1,1);
                for k = 1:c
                    varargout{k} = complex(dataRAW(index,:),dataRAW(index+1,:)).';
                    index = index+2;
                end
                varargout{end} = valid;
            else
                varargout = cell(1,1);
                varargout{1} = true;
            end
        end
        
    end
    
end

