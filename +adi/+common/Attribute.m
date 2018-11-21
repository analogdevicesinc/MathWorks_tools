classdef (Abstract) Attribute < matlabshared.libiio.base 
    % Attribute IIO attribute function calls
    
    methods (Hidden, Access = protected)
        
        function setAttributeLongLong(obj,id,attr,value,isOutput,tol)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            status = iio_channel_attr_write_longlong(obj,chanPtr,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' num2str(value)]);
            % Check
            [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
            if nargin<6
                tol = sqrt(eps);
            end
            if abs(value - rValue) > tol
                status = -1;
                cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
            end
        end
        
        function setAttributeBool(obj,id,attr,value,isOutput)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            status = iio_channel_attr_write_bool(obj,chanPtr,attr,value);
            cstatus(obj,status,['Attribute write failed for : ' attr]);
            % Check
            [status, rValue] = iio_channel_attr_read_bool(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
            if value ~= rValue
                status = -1;
                cstatus(obj,status,['Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
            end
        end
        
        function setAttributeRAW(obj,id,attr,value,isOutput)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            bytes = iio_channel_attr_write(obj,chanPtr,attr,value);
            if bytes <= 0
                status = -1;
                cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' value]);
            end
        end
        
    end
end
