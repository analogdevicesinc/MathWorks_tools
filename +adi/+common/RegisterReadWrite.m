classdef (Abstract) RegisterReadWrite < matlabshared.libiio.base 
    
    methods (Hidden, Access = protected)
        function setRegister(obj,settings)
            phydev = getDev(obj, obj.phyDevName);
            value = settings{1};
            if (numel(settings) == 5)
                value = value*2^(settings{5});
            end
            addr_dec = hex2dec(settings{3});
            mask = bin2dec(settings{4});
            [status, curr_val] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' settings{3}]);
            new_val = bitxor(value, bitand(bitxor(value, curr_val), mask));            
            status = iio_device_reg_write(obj,phydev,addr_dec,new_val);
            cstatus(obj,status,['Address write failed for : ' settings{3} ' with value ' num2str(value)]);
            % Check
            [status, rValue] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' settings{3}]);
            if nargin<6
                tol = sqrt(eps);
            end
            if abs(value - rValue) > tol
                status = -1;
                % cstatus(obj,status,['Address ' settings{3} ' contents ' num2str(rValue) ', expected ' num2str(value)]);
            end            
        end
        
        function value = getRegister(obj,addr)
            phydev = getDev(obj, obj.phyDevName);
            addr_dec = hex2dec(addr);
            % Check
            [status, value] = iio_device_reg_read(obj,phydev,addr_dec);
            cstatus(obj,status,['Error reading address: ' addr]);            
        end        
        
    end    
end