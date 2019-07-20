classdef (Abstract) Rx  < adi.common.RxTx
    % Rx: Common shared functions between receiver classes
    properties(Constant, Hidden, Logical)
        %EnableCyclicBuffers Enable Cyclic Buffers
        %   Not used for RX
        EnableCyclicBuffers = false;
    end
    
    methods (Access=protected)

        function numOut = getNumOutputsImpl(~)
            numOut = 2;
        end
        
        function names = getOutputNamesImpl(~)
            % Return output port names for System block
            names = {'data','valid'};
        end
        
        function sizes = getOutputSizeImpl(obj)
            % Return size for each output port
            sizes = {[obj.SamplesPerFrame,obj.channelCount],[1,1]};
        end
        
        function types = getOutputDataTypeImpl(~)
            % Return data type for each output port
            types = ["int16","logical"];
        end
        
        function complexities = isOutputComplexImpl(obj)
            % Return true for each output port with complex data
            complexities = {obj.ComplexData,false};
        end
        
        function fixed = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            fixed = {true,true};
        end
    end
    
    methods (Hidden, Access = protected)
        
        function [data,valid] = stepImpl(obj)
            % Get the data            
            if obj.ComplexData
                kd = 1;
                ce = length(obj.EnabledChannels);
                [dataRAW, valid] = getData(obj);
                data = complex(zeros(obj.SamplesPerFrame,ce));
                for k = 1:ce
                    data(:,k) = complex(dataRAW(kd,:),dataRAW(kd+1,:)).';
                    kd = kd + 2;
                end
            else
                [data, valid] = getData(obj);
                data = data.';
            end
            
        end
        
    end
    
end

