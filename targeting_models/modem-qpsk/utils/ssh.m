classdef ssh
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        username = 'root'
        password = 'analog'
        IPAddress = '192.168.3.2'
    end
    
    properties (Hidden = true)
        folder
        mounted = false;
        mount
    end
    
    methods
        function obj = ssh()
            if ispc || ismac
                error('ssh only tested on Linux');
            end
            obj.folder = char(randi([int8('A'),int8('Z')],1,10));
        end
        
        function delete(obj)
           if obj.mounted
               obj.doremote(['umount ',obj.mount]);
           end
        end
        
        function doremote(obj,cmds)
            command = ['ssh ',obj.username,'@',obj.IPAddress,' ',cmds];
            obj.check(system(command),['Remote command failed: ',cmds]);
        end
        
        function path = findBOOTBIN(~)
            [~,b] = system('find . -name BOOT.BIN');
            if isempty(b)
                error('Cannot find BOOT.BIN within current path');
            else
                path = strtrim(b);
            end
        end
        
        function check(obj,s,msg)
            if s
                if obj.mounted
                    obj.doremote(['umount ',obj.mount]);
                end
                error(msg);
            end
        end
        
        function copyfile(obj,filename)
            obj.doremote(['mkdir -p /tmp/',obj.folder]);
            command = ['scp ',filename,' ',obj.username,'@',obj.IPAddress,':','/tmp/',obj.folder,'/'];
            obj.check(system(command),'Copy failed');
        end
        
        function updateFPGA(obj,filename)
            if isempty(filename)
                filename = obj.findBOOTBIN();
                disp('Automatically found: ',filename);
            else
                obj.check(exist(filename, 'file') ~= 2,'File does not exists');
            end
            obj.mount = '/media/mount';
            obj.doremote(['mkdir -p ',obj.mount]);
            % Mount boot directory
            obj.doremote(['mount /dev/mmcblk0p1 ',obj.mount]);
            obj.mounted = true;
            obj.copyfile(filename);
            % Move BOOT.BIN to boot
            obj.doremote(['cp /tmp/',obj.folder,'/BOOT.BIN ',obj.mount]);            
            % Cleanup
            obj.doremote(['umount ',obj.mount]);
            % Reboot
            obj.doremote('reboot');            
        end
        
    end
end

