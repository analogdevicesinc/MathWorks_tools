classdef (Abstract) Sensor  < adi.common.RxTx & adi.common.Attribute
    % Sensor: Common shared functions between sensor classes
    properties(Constant, Hidden, Logical)
        EnableCyclicBuffers = false;
    end
    properties (Abstract, Hidden, Constant)
        SensorAttributeNames
        SensorAttributeTypes
    end
    properties (Abstract, Hidden)
       SensorAttributeScales
    end
    methods (Hidden, Access = protected)
        
        function varargout = stepImpl(obj)
            % Get the data
            c = length(obj.SensorAttributeNames);
            data = zeros(obj.SamplesPerFrame,c);
            for i = 1:obj.SamplesPerFrame
                for k = 1:c
                    switch obj.SensorAttributeTypes{k}
                        case 'LongLong'
                            data(i,k) = obj.getAttributeLongLong(...
                                obj.SensorAttributeNames{k},'raw',0) * ...
                                obj.SensorAttributeScales(k);
                        case 'Double'
                            data(i,k) = obj.getAttributeDouble(...
                                obj.SensorAttributeNames{k},'raw',0) * ...
                                obj.SensorAttributeScales(k);
                        case 'Raw'
                            data(i,k) = obj.getAttributeRAW(...
                                obj.SensorAttributeNames{k},'raw',0);
                            
                    end
                end
            end
            varargout = cell(c,1);
            for k=1:c
                varargout{k} = data(:,k);
            end
        end
        
        function scales = CollectScales(obj)
            % Get the data
            c = length(obj.SensorAttributeNames);
            scales = zeros(c,1);
            for k = 1:c
                scales(k) = obj.getAttributeDouble(...
                    obj.SensorAttributeNames{k},'scale',0);
            end
        end
        
    end
    
end

