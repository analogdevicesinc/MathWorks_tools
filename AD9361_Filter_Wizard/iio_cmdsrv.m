%  Copyright 2014(c) Analog Devices, Inc.
%
%  All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without modification,
%  are permitted provided that the following conditions are met:
%      - Redistributions of source code must retain the above copyright
%        notice, this list of conditions and the following disclaimer.
%      - Redistributions in binary form must reproduce the above copyright
%        notice, this list of conditions and the following disclaimer in
%        the documentation and/or other materials provided with the
%        distribution.
%      - Neither the name of Analog Devices, Inc. nor the names of its
%        contributors may be used to endorse or promote products derived
%        from this software without specific prior written permission.
%      - The use of this software may or may not infringe the patent rights
%        of one or more patent holders.  This license does not release you
%        from the requirement that you obtain separate licenses from these
%        patent holders to use this software.
%      - Use of the software either in source or binary form or filter designs
%        resulting from the use of this software, must be connected to, run
%        on or loaded to an Analog Devices Inc. component.
%
%  THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
%  INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
%  PARTICULAR PURPOSE ARE DISCLAIMED.
%
%  IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
%  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
%  RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
%  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
%  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
%  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

classdef iio_cmdsrv < handle
    %IIO_CMDSRV Matlab client for the IIO Command Server
    %   Implements the API to interract with the Linux IIO Command Server
    %   over UDP
    
    properties (SetAccess=private)
        hudpr; % UDP Receiver object
        hudps; % UDP Sender object
    end
    
    properties (GetAccess=private, SetAccess=private)
        srv_addr = '127.0.0.1';         % Server IP Address
        srv_port = 25000;               % Server port
        IIO_CMDSRV_MAX_RETVAL = 13;     % Maximum command length returned by the server
        IIO_CMDSRV_MAX_STRINGVAL = 512; % Maximum string length returned by the server
        IIO_CMDSRV_MAX_MSG_LEN = 4096;  % Maximum message length to be sent to the server
    end
    
    methods (Access = private)
        
        function [ret, rbuf, rbuf2, rlen2] = srv_receive(obj, rlen, has_buf2, is_str)
            % Receives from the server a specified number of bytes
            % Parameters:
            %   - rlen: number of bytes to receive
            %   - has_buf2: if set to 1 the received data is split in rbuf
            %   and rbuf2 at the first occurence of the \n character
            %   - is_str: if set to 1 the returned data is converted into a
            %   string
            % Return:
            %   - ret: Set to -1 for error, 0 if the entire respose was
            %   received, 1 otherwise
            %   - rbuf: Buffer to store the received data
            %   - rbuf2: Buffer to store the received data following the
            %   first \n character in the received packet
            %   - rlen2: stores the number of bytes after the first \n
            %   found in the received stream
            
            term = 1;
            retry = 1;
            i = 0;
            len = 0;
            rbuf = '';
            rbuf2 = '';
            rlen2 = 0;
            
            while ((len < rlen) && term)
                dataReceived = step(obj.hudpr);
                rx_len = length(dataReceived);
                if(rx_len == 0)
                    retry = retry - 1;
                    if(retry == 0)
                        ret = -1;
                        return;
                    end
                    continue;
                end
                
                len = len + rx_len;
                rbuf = [rbuf char(dataReceived)];
                
                if (is_str == 1)
                    for i = 1 : len
                        if (rbuf(i) == char(10))
                            term = 0;
                            rbuf(i) = 0;
                            break;
                        end
                    end
                end
                
                if (rx_len == 0)
                    term = 0;
                end
            end
            
            if(has_buf2 ~= 0)
                s = i + 1;
                rlen2 = 0;
                for i = s : len
                    rlen2 = rlen2 + 1;
                    rbuf2(rlen2) = rbuf(i);
                end
            end
            
            if(has_buf2 ~= 0 && rlen2 == 0)
                rlen2 = 1;
                while (rbuf(rlen2) ~= 0)
                    rbuf2(rlen2) = rbuf(rlen2);
                    rlen2 = rlen2 + 1;
                end
                rbuf2(rlen2) = 0;
            end
            
            ret = term;
        end
        
        function ret = iio_cmd_send_va(obj, str, varargin)
            % Sends a variable length command to the IIO server
            % Parameters:
            %   - str: command format
            %   - varargin: command parameters
            % Return:
            %   - ret: Set to -1 for error
            
            buf = sprintf(str, cell2mat(varargin{1}));
            len = length(buf);
            
            step(obj.hudps, uint8(buf));
            [ret, rbuf] = obj.srv_receive(obj.IIO_CMDSRV_MAX_RETVAL, 0, 1);
            if (ret >= 0)
                [ret1, cnt] = sscanf(rbuf, '%d\n');
                if(cnt == 1)
                    ret = ret1(1);
                end
            end
        end
        
        function [ret, rbuf] = iio_cmd_read_va(obj, rlen, str, varargin)
            % Reads data from the server using a variable length command
            % Parameters:
            %   - rlen: length in bytes of the data to receive
            %   - str: command format
            %   - varargin: command parameters
            % Return:
            %   - ret: set to -1 for error
            %   - rbuf: buffer which stores the received data
            
            buf = sprintf(str, cell2mat(varargin{1}));
            len = length(buf);
            
            step(obj.hudps, uint8(buf));
            [ret, retval, rbuf, rx_len] = obj.srv_receive(rlen, 1, 1);
            
            if (ret >= 0)
                [ret, cnt] = sscanf(retval, '%d\n');
                ret = ret(1);
                if ((cnt == 1) && (ret >= 0))
                    % Already received the entire response ?
                    if (rbuf(rx_len) == 0 || rbuf(rx_len) == char(10))
                        rbuf(rx_len) = 0;
                        return;
                    end
                    [ret, retval] = obj.srv_receive(rlen - rx_len, 0, 1);
                    rbuf = [rbuf retval];
                end
            end
        end
    end
    
    methods (Access = public)
        
        function ret = iio_cmdsrv_connect(obj, addr, port)
            % Connects to the IIO server
            % Parameters:
            %   - addr: IP address of the IIO server
            %   - port: port to send / receive data
            % Return:
            %   - ret: set to -1 for error
            
            obj.srv_addr = addr;
            obj.srv_port = port;
            
            obj.hudpr = dsp.UDPReceiver;
            obj.hudpr.LocalIPPort = port;
            obj.hudpr.BlockingTime = 1;
            step(obj.hudpr);
            
            obj.hudps = dsp.UDPSender;
            obj.hudps.RemoteIPAddress = addr;
            obj.hudps.RemoteIPPort = port;
            obj.hudps.LocalIPPort = port;
            obj.hudps.LocalIPPortSource = 'Property';
            
            ret = 0;
        end
        
        function ret = iio_cmdsrv_disconnect(obj)
            % Disconnects from the IIO server
            % Return:
            %   - ret: set to -1 for error
            
            ret = obj.iio_cmd_send('quit\n') * (-1);
            release(obj.hudps);
            release(obj.hudpr);
        end
        
        function ret = iio_cmd_send(obj, str, varargin)
            % Sends a command to the IIO server
            % Parameters:
            %   - str: command format
            %   - varargin: command parameters
            % Return:
            %   - ret: set to -1 for error
            
            ret = obj.iio_cmd_send_va(str, varargin);
            if (ret < 0)
                obj.iio_cmdsrv_connect(obj.srv_addr, obj.srv_port);
                ret = obj.iio_cmd_send_va(str, varargin);
            end
        end
        
        function [ret, rbuf] =  iio_cmd_read(obj, rlen, str, varargin)
            % Reads data from the server using a variable length command
            % Parameters:
            %   - rlen: length in bytes of the data to receive
            %   - str: command format
            %   - varargin: command parameters
            % Return:
            %   - ret: set to -1 for error
            %   - rbuf: buffer which stores the received data
            
            [ret, rbuf] = obj.iio_cmd_read_va(rlen, str, varargin);
            if (ret < 0)
                obj.iio_cmdsrv_connect(obj.srv_addr, obj.srv_port);
                [ret, rbuf] = obj.iio_cmd_read_va(rlen, str, varargin);
            end
        end
        
        function [ret, rbuf] = iio_cmd_sample(obj, name, count, bytes_per_sample)
            % Reads a number of samples from a specified device
            % Parameters:
            %   - name: name of the device to read data from
            %   - count: number of samples to read
            %   - bytes_per_sample: byter per sample
            % Return:
            %   - ret: set to -1 for error
            %   - rbuf: buffer which stores the received data
            
            rbuf = '';
            buf = sprintf('sample %s %d %d\n', name, count, bytes_per_sample);
            len = length(buf);
            if (len < 0)
                print('iio_cmd_send\n');
            end
            
            step(obj.hudps, uint8(buf));
            [ret, buf] = obj.srv_receive(obj.IIO_CMDSRV_MAX_RETVAL, 0, 1);
            if (ret >= 0)
                [retval, cnt] = sscanf(buf, '%d\n');
                if ((cnt == 1) && (retval >= 0))
                    [ret, rbuf] = obj.srv_receive(retval, 0, 0);
                    if (ret >= 0)
                        ret = retval;
                    end
                end
            end
        end
        
        function [ret, val] = iio_cmd_regread(obj, name, reg)
            % Reads a register from a specified device
            % Parameters:
            %   - name: name of the device to read data from
            %   - reg: register address
            % Return:
            %   - ret: set to -1 for error
            %   - val: register value
            
            val = 0;
            cmd = sprintf('regread %s %d\n', name, reg);
            [ret, buf] = obj.iio_cmd_read(obj.IIO_CMDSRV_MAX_STRINGVAL, cmd);
            if (ret >= 0)
                [val, cnt] = sscanf(buf, '%i\n');
                if (cnt == 1)
                    ret = 0;
                else
                    ret = -1;
                end
            end
        end
        
        function ret = iio_cmd_regwrite(obj, name, reg, val)
            % Writes a register from a specified device
            % Parameters:
            %   - name: name of the device to read data from
            %   - reg: register address
            %   - val: value to write
            % Return:
            %   - ret: set to -1 for error
            
            cmd = sprintf('regwrite %s %d %d\n', name, reg, val);
            ret = obj.iio_cmd_send(cmd);
        end
        
        function ret = iio_cmd_bufwrite(obj, name, wbuf, count)
            % Writes a data buffer to a specified device
            % Parameters:
            %   - name: name of the device to read data from
            %   - wbuf: buffer containing the data to write
            %   - count: number of bytes to write
            % Return:
            %   - ret: set to -1 for error
            
            buf = sprintf('bufwrite %s %d\n', name, count);
            step(obj.hudps, uint8(buf));
            for idx = 1 : obj.IIO_CMDSRV_MAX_MSG_LEN : count
                if(idx + obj.IIO_CMDSRV_MAX_MSG_LEN < count)
                    step(obj.hudps, uint8(wbuf(idx : idx + obj.IIO_CMDSRV_MAX_MSG_LEN - 1)));
                    % a small delay to avoid the server from clogging
                    for idx1 = 1 : obj.IIO_CMDSRV_MAX_MSG_LEN
                    end
                else
                    step(obj.hudps, uint8(wbuf(idx : count)));
                end
            end
            ret = 1;
        end
    end
    
end