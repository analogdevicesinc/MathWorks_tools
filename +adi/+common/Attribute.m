classdef (Abstract) Attribute < matlabshared.libiio.base 
    % Attribute IIO attribute function calls
    
    methods (Hidden)
        
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
        
        function rValue = getAttributeLongLong(obj,id,attr,isOutput)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read_longlong(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
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
        
        function rValue = getAttributeBool(obj,id,attr,isOutput)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read_bool(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
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
        
        function rValue = getAttributeRAW(obj,id,attr,isOutput)
            phydev = getDev(obj, obj.phyDevName);
            chanPtr = iio_device_find_channel(obj,phydev,id,isOutput);%FIXME (INVERSION)
            status = cPtrCheck(obj,chanPtr);
            cstatus(obj,status,['Channel: ' id ' not found']);
            [status, rValue] = iio_channel_attr_read(obj,chanPtr,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end
        
        function setDeviceAttributeRAW(obj,attr,value)
            phydev = getDev(obj, obj.phyDevName);
            bytes = iio_device_attr_write(obj,phydev,attr,value);
            if bytes <= 0
                status = -1;
                cstatus(obj,status,['Attribute write failed for : ' attr ' with value ' value]);
            end
        end
        
        function rValue = getDeviceAttributeRAW(obj,attr)
            phydev = getDev(obj, obj.phyDevName);
            [status, rValue] = iio_device_attr_read(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end
        
        function setDeviceAttributeLongLong(obj,attr,value,tol)
            phydev = getDev(obj, obj.phyDevName);
            status = iio_device_attr_write_longlong(obj,phydev,attr,value);
            cstatus(obj,status,['Device Attribute write failed for : ' attr ' with value ' num2str(value)]);
            % Check
            [status, rValue] = iio_device_attr_read_longlong(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
            if nargin<6
                tol = sqrt(eps);
            end
            if abs(value - rValue) > tol
                status = -1;
                cstatus(obj,status,['Device Attribute ' attr ' return value ' num2str(rValue) ', expected ' num2str(value)]);
            end
        end

        function rValue = getDeviceAttributeLongLong(obj,attr)
            phydev = getDev(obj, obj.phyDevName);
            [status, rValue] = iio_device_attr_read_longlong(obj,phydev,attr);
            cstatus(obj,status,['Error reading attribute: ' attr]);
        end


    end
end
