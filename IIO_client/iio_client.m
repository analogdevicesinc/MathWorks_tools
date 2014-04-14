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

function varargout = iio_client(varargin)
% IIO_CLIENT MATLAB code for iio_client.fig
%      IIO_CLIENT, by itself, creates a new IIO_CLIENT or raises the existing
%      singleton*.
%
%      H = IIO_CLIENT returns the handle to a new IIO_CLIENT or the handle to
%      the existing singleton*.
%
%      IIO_CLIENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IIO_CLIENT.M with the given input arguments.
%
%      IIO_CLIENT('Property','Value',...) creates a new IIO_CLIENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iio_client_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iio_client_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help iio_client

% Last Modified by GUIDE v2.5 03-Apr-2014 13:14:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @iio_client_OpeningFcn, ...
                   'gui_OutputFcn',  @iio_client_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before iio_client is made visible.
function iio_client_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to iio_client (see VARARGIN)

% Choose default command line output for iio_client
handles.output = hObject;
hide_buttons(handles);
handles.iio_cmdsrv = {};
handles.timer = {};

try
tmp = evalin('base', 'IIO_ip_address');
set(handles.ip_address,'String', tmp);
catch
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes iio_client wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = iio_client_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function hide_buttons(handles)
set(handles.iio_devices, 'Visible', 'off');
set(handles.iio_attributes, 'Visible', 'off');
set(handles.iio_capture, 'Visible', 'off');
set(handles.iio2workspace, 'Visible', 'off');
set(handles.iio_attribute_value, 'Visible', 'off');
set(handles.iio_write_attribute, 'Visible', 'off');
set(handles.num_samples, 'Visible', 'off');
set(handles.text_devices, 'Visible', 'off');
set(handles.text_dev_attr, 'Visible', 'off');
set(handles.text_data_capture, 'Visible', 'off');
set(handles.text_sample_no, 'Visible', 'off');
set(handles.pushbutton6, 'Visible', 'off');

function populate_attribute_value(handles)
device = cellstr(get(handles.iio_devices, 'String'));
device = char(device(get(handles.iio_devices, 'Value')));

attribute = cellstr(get(handles.iio_attributes, 'String'));
attribute = char(attribute(get(handles.iio_attributes, 'Value')));

%TODO : This doesn't seem to work
[ret, rbuf] = iio_cmd_read(handles.iio_cmdsrv, 2048, 'read %s\n', [device ' ' attribute]);

if ret ~= -1
    rbuf = strtrim(rbuf);
    set(handles.iio_attribute_value, 'String', rbuf);
end

function device = get_device(handles)
device = cellstr(get(handles.iio_devices, 'String'));
device = char(device(get(handles.iio_devices, 'Value')));

function populate_attributes(handles)
device = get_device(handles);

[ret, rbuf] = iio_cmd_read(handles.iio_cmdsrv, 512, 'show %s .\n', device);
tmp = strsplit(rbuf);
set(handles.iio_attributes, 'String', tmp);
% if the selected device is AD9361 enable all the data channels
if(strcmp(device, 'cf-ad9361-lpc') == 1)
    ret = iio_cmd_send(handles.iio_cmdsrv, 'write %s\n', [device ' scan_elements/in_voltage0_en 1'])
    ret = iio_cmd_send(handles.iio_cmdsrv, 'write %s\n', [device ' scan_elements/in_voltage1_en 1'])
    ret = iio_cmd_send(handles.iio_cmdsrv, 'write %s\n', [device ' scan_elements/in_voltage2_en 1'])
    ret = iio_cmd_send(handles.iio_cmdsrv, 'write %s\n', [device ' scan_elements/in_voltage3_en 1'])
end

% --- Executes on button press in iio_connect.
function iio_connect_Callback(hObject, eventdata, handles)
% hObject    handle to iio_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = get(handles.ip_address,'String');
assignin('base', 'IIO_ip_address', tmp);

tmp = strsplit(tmp, ':');
ip=char(tmp(1));
if length(tmp) == 2
    port = str2num(char(tmp(2)));
    if ~ port
        port = 1234;
    end
else
    port = 1234;
end



obj = iio_cmdsrv;
iio_cmdsrv_connect(obj, ip, port);
[ret, rbuf] = iio_cmd_read(obj, 200, 'version\n');
if(ret ~= -1)
    handles.iio_cmdsrv = obj;
    
    % Populate devices
    [ret, rbuf] = iio_cmd_read(obj, 200, 'show\n');
    tmp = strsplit(rbuf);
    set(handles.iio_devices, 'String', tmp);
    
    %populate the rest
    populate_attributes(handles);
    set(handles.iio_attributes, 'Value', 2);
    populate_attribute_value(handles);
    
    set(handles.iio_devices, 'Visible', 'on');
    set(handles.iio_attributes, 'Visible', 'on');
    set(handles.iio_capture, 'Visible', 'on');
    set(handles.iio2workspace, 'Visible', 'on');
    set(handles.iio_attribute_value, 'Visible', 'on');
    set(handles.iio_write_attribute, 'Visible', 'on');
    set(handles.num_samples, 'Visible', 'on');
    set(handles.text_devices, 'Visible', 'on');
    set(handles.text_dev_attr, 'Visible', 'on');
    set(handles.text_data_capture, 'Visible', 'on');
    set(handles.text_sample_no, 'Visible', 'on');
    set(handles.pushbutton6, 'Visible', 'on');
else
    msgbox('Could not connect to target!', 'Error','error');
    hide_buttons(handles);
end
% Update handles structure
guidata(hObject, handles);


function ip_address_Callback(hObject, eventdata, handles)
% hObject    handle to ip_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ip_address as text
%        str2double(get(hObject,'String')) returns contents of ip_address as a double


% --- Executes during object creation, after setting all properties.
function ip_address_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ip_address (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function my_capture_Callback(obj, event, string_arg)
handles = obj.UserData;
num_samples = str2num(get(handles.num_samples, 'String'))*2;
device = get_device(handles);
[ret, rbuf] = iio_cmd_sample(handles.iio_cmdsrv, device, num_samples*2, 2);
if(ret > 0)
    data = uint16(rbuf(2:2:end))*2^8 + uint16(rbuf(1:2:end));
    data = int32(data);
    data(data>2^15)= data(data>2^15)-2^16;    
    
    %plot the time domain data
    t = 1:length(data)/4;
    plot(handles.ch1_data, t, data(1:4:end), 'b', t, data(2:4:end), 'r'); grid(handles.ch1_data);    
    xlim(handles.ch1_data, [0 num_samples/2]);
    ylim(handles.ch1_data, [min(data)*1.1 max(data)*1.1]);
    plot(handles.ch2_data, t, data(3:4:end), 'b', t, data(4:4:end), 'r'); grid(handles.ch2_data);
    xlim(handles.ch2_data, [0 num_samples/2]);
    ylim(handles.ch2_data, [min(data)*1.1 max(data)*1.1]);
    
    %plot the FFT
    sample_rate = 30720000;
    f = -sample_rate/2:sample_rate/(num_samples/2):sample_rate/2;
    signal1 = complex(double(data(1:4:end)), double(data(2:4:end)));
    signal2 = complex(double(data(3:4:end)), double(data(4:4:end)));
    Nsignal = length(data(1:4:end));
    w = hamming(Nsignal);
    newsignal1 = signal1.*w;
    newsignal2 = signal2.*w;
    fdata1 = 20*log10(abs(fftshift(fft(newsignal1), Nsignal)))/Nsignal;
    plot(handles.ch1_fft, f(1:end-1), fdata1); grid(handles.ch1_fft);
    xlim(handles.ch1_fft, [f(1) f(end)]);
    ylim(handles.ch1_fft, [min(fdata1)*1.1 max(fdata1)*1.1]);    
    fdata2 = 20*log10(abs(fftshift(fft(newsignal2), Nsignal)))/Nsignal;
    plot(handles.ch2_fft, f(1:end-1), fdata2); grid(handles.ch2_fft);
    xlim(handles.ch2_fft, [f(1) f(end)]);
    ylim(handles.ch2_fft, [min(fdata2)*1.1 max(fdata2)*1.1]);
end

% --- Executes on button press in iio_capture.
function iio_capture_Callback(hObject, eventdata, handles)
% hObject    handle to iio_capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_samples = str2num(get(handles.num_samples, 'String'))*2;
device = get_device(handles);

[ret, rbuf] = iio_cmd_sample(handles.iio_cmdsrv, device, num_samples*2, 2);
if(ret > 0)
    data = uint16(rbuf(2:2:end))*2^8 + uint16(rbuf(1:2:end));
    data = int32(data);
    data(data>2^15)= data(data>2^15)-2^16;    
    
    %plot the time domain data
    t = 1:length(data)/4;
    plot(handles.ch1_data, t, data(1:4:end), 'b', t, data(2:4:end), 'r'); grid(handles.ch1_data);    
    xlim(handles.ch1_data, [0 num_samples/2]);
    ylim(handles.ch1_data, [min(data)*1.1 max(data)*1.1]);
    plot(handles.ch2_data, t, data(3:4:end), 'b', t, data(4:4:end), 'r'); grid(handles.ch2_data);
    xlim(handles.ch2_data, [0 num_samples/2]);
    ylim(handles.ch2_data, [min(data)*1.1 max(data)*1.1]);
    
    %plot the FFT
    sample_rate = 30720000;
    f = -sample_rate/2:sample_rate/(num_samples/2):sample_rate/2;
    fdata1 = 20*log10(abs(fftshift(fft(complex(double(data(1:4:end)), double(data(2:4:end))), length(data(1:4:end)))))/length(data(1:4:end)));
    plot(handles.ch1_fft, f(1:end-1), fdata1); grid(handles.ch1_fft);
    xlim(handles.ch1_fft, [f(1) f(end)]);
    ylim(handles.ch1_fft, [min(fdata1)*1.1 max(fdata1)*1.1]);    
    fdata2 = 20*log10(abs(fftshift(fft(complex(double(data(3:4:end)), double(data(4:4:end))), length(data(3:4:end)))))/length(data(3:4:end)));
    plot(handles.ch2_fft, f(1:end-1), fdata2); grid(handles.ch2_fft);
    xlim(handles.ch2_fft, [f(1) f(end)]);
    ylim(handles.ch2_fft, [min(fdata2)*1.1 max(fdata2)*1.1]);
end

% --- Executes on selection change in iio_attributes.
function iio_attributes_Callback(hObject, eventdata, handles)
% hObject    handle to iio_attributes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
populate_attribute_value(handles);
% Hints: contents = cellstr(get(hObject,'String')) returns iio_attributes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iio_attributes


% --- Executes during object creation, after setting all properties.
function iio_attributes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iio_attributes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function iio_attribute_value_Callback(hObject, eventdata, handles)
% hObject    handle to iio_attribute_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of iio_attribute_value as text
%        str2double(get(hObject,'String')) returns contents of iio_attribute_value as a double


% --- Executes during object creation, after setting all properties.
function iio_attribute_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iio_attribute_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in iio_write_attribute.
function iio_write_attribute_Callback(hObject, eventdata, handles)
% hObject    handle to iio_write_attribute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in iio2workspace.
function iio2workspace_Callback(hObject, eventdata, handles)
% hObject    handle to iio2workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

num_samples = str2num(get(handles.num_samples, 'String'))*2;
device = get_device(handles);

[ret, rbuf] = iio_cmd_sample(handles.iio_cmdsrv, device, num_samples*2, 2);
if(ret > 0)
    data = uint16(rbuf(2:2:end))*2^8 + uint16(rbuf(1:2:end));
    data = int32(data);
    data(data>2^15)= data(data>2^15)-2^16;    
    
    assignin('base', 'Channel_1_I', data(1:4:end));
    assignin('base', 'Channel_1_Q', data(2:4:end));
    assignin('base', 'Channel_2_I', data(3:4:end));
    assignin('base', 'Channel_2_Q', data(4:4:end));
end

% --- Executes on selection change in iio_devices.
function iio_devices_Callback(hObject, eventdata, handles)
% hObject    handle to iio_devices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
populate_attributes(handles);
populate_attribute_value(handles);

% Hints: contents = cellstr(get(hObject,'String')) returns iio_devices contents as cell array
%        contents{get(hObject,'Value')} returns selected item from iio_devices


% --- Executes during object creation, after setting all properties.
function iio_devices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to iio_devices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_samples_Callback(hObject, eventdata, handles)
% hObject    handle to num_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_samples as text
%        str2double(get(hObject,'String')) returns contents of num_samples as a double


% --- Executes during object creation, after setting all properties.
function num_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.pushbutton6, 'String'), 'Start Data Streaming') == 1)
    handles.timer = timer('StartDelay', 1, 'Period', 1, 'ExecutionMode', 'fixedRate');
    handles.timer.TimerFcn = {@my_capture_Callback, ''};
    handles.timer.UserData = handles;
    start(handles.timer);
    set(handles.pushbutton6, 'String', 'Stop Data Streaming');
else
    stop(handles.timer);
    delete(handles.timer);
    set(handles.pushbutton6, 'String', 'Start Data Streaming');
end
guidata(hObject, handles);
