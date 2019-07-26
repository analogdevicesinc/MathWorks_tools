classdef (Abstract) Rx  < adi.common.RxTx & matlab.system.mixin.SampleTime
    % Rx: Common shared functions between receiver classes
    properties(Constant, Hidden, Logical)
        %EnableCyclicBuffers Enable Cyclic Buffers
        %   Not used for RX
        EnableCyclicBuffers = false;
    end
    
    methods (Hidden, Access = protected)
        
        function sts = getSampleTimeImpl(obj)
            sts = createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SamplesPerFrame/obj.SamplingRate);
        end
        
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
            % [data,valid] = rx() returns data received from the radio
            % hardware associated with the receiver System object, rx.
            % The output 'valid' indicates whether the object has received 
            % data from the radio hardware. The first valid data frame can
            % contain transient values, resulting in packets containing 
            % undefined data.
            %
            % The output 'data' will be an [NxM] vector where N is
            % 'SamplesPerFrame' and M is the number of elements in
            % 'EnabledChannels'. 'data' will be complex if the devices
            % assumes complex data operations.
            
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

