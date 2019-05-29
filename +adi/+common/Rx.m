classdef (Abstract) Rx  < adi.common.RxTx
    % Rx: Common shared functions between receiver classes
    properties(Constant, Hidden, Logical)
        EnableCyclicBuffers = false;
    end
    
    properties (Abstract, Hidden, Logical)
       ComplexData 
    end
    
    methods (Hidden, Access = protected)
        
        function varargout = stepImpl(obj)
            % Get the data
            
            if obj.ComplexData
                c = obj.channelCount/2;
                % Complex output
                if c > 0
                    [dataRAW, valid] = getData(obj);
                    index = 1;
                    data = coder.nullcopy(complex(zeros(obj.SamplesPerFrame,c,'int16')));
                    for k = 1:c
                        data(:,k) = complex(dataRAW(index,:),dataRAW(index+1,:)).';
                        index = index+2;
                    end
                    varargout = cell(2,1);
                    varargout{1} = data;
                    varargout{2} = valid;
                else
                    varargout = cell(1,1);
                    varargout{1} = true;
                end
            else
                c = obj.channelCount;
                if c > 0
                    [dataRAW, valid] = getData(obj);
                    varargout = cell(2,1);
                    varargout{1} = dataRAW.';
                    varargout{2} = valid;
                else
                    varargout = cell(1,1);
                    varargout{1} = true;
                end
            end
            
            
        end
        
    end
    
end

