classdef (Abstract) Tx  < adi.common.RxTx & adi.common.DDS
    % Tx: Common shared functions between transmitter classes
    
    methods (Hidden, Access = protected)
        
        function numIn = getNumInputsImpl(obj)
            if strcmp(obj.DataSource,'DDS')
                numIn = 0;
            else
                numIn = 1;
            end
        end
        
    end
    
    methods (Hidden, Access = protected)
        
        function valid = stepImpl(obj,dataIn)
            
            if strcmp(obj.DataSource,'DMA')
                %%
                if obj.ComplexData
                    % Interleave channels include I and Q
                    c = obj.channelCount;
                    s = size(dataIn);
                    assert(s(2)==c/2,sprintf('Data size must [Nx%d]\n',c/2));
                    index = 1;
                    %
                    outputData = complex(zeros(length(dataIn)*c,1));
                    for k = 1:2:c
                        outputData(k+0:c:end,1) = real(int16(dataIn(:,index).'));
                        outputData(k+1:c:end,1) = imag(int16(dataIn(:,index).'));
                        index = index + 1;
                    end
                    
                else
                    %%
                    c = obj.channelCount;
                    s = size(dataIn);
                    assert(s(2)==c,sprintf('Data size must [Nx%d]\n',c));
                    %
                    outputData = zeros(length(dataIn)*c,1);
                    for k = 1:c
                        outputData(k:c:end,1) = int16(dataIn(:,k).');
                    end
                end
                %%
                valid = sendData(obj,outputData);
            else
                valid = true;
                obj.DDSUpdate();
            end            
        end
        
    end
    
end

