classdef (Abstract) Tx  < adi.common.RxTx
    % Tx: Common shared functions between transmitter classes
    
    methods (Hidden, Access = protected)
        
        function stepImpl(obj,varargin)
            
            if strcmp(obj.DataSource,'DMA')
                % Interleave channels include I and Q
                c = obj.channelCount;
                outputData = complex(zeros(length(varargin{1}), c));
                index = 1;
                for k = 1:c
                    if fix(k/2)==k/2
                        outputData(:,k) = imag(int16(varargin{index,:}).');
                        index = index + 1;
                    else
                        outputData(:,k) = real(int16(varargin{index,:}).');
                    end
                end
                outputData = reshape(outputData.',numel(outputData),1);
                sendData(obj,outputData);
            else
                obj.DDSUpdate();
            end
            
        end
        
        function ToggleDDS(obj,value)
            chanPtr = getChan(obj,'altvoltage0',true);
            iio_channel_attr_write_bool(obj,chanPtr,'raw',value);
        end
        
        function DDSUpdate(obj)
            obj.ToggleDDS(true);
            for k=1:4
                id = sprintf('altvoltage%d',k-1);
                chanPtr = getChan(obj,id,true);
                iio_channel_attr_write_double(obj,chanPtr,'frequency',obj.DDSFrequencies(k));
                iio_channel_attr_write_double(obj,chanPtr,'scale',obj.DDSScales(k));
                iio_channel_attr_write_double(obj,chanPtr,'phase',obj.DDSPhases(k));
            end
        end
    end
    
end

