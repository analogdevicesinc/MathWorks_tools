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

% Last Modified by GUIDE v2.5 01-Apr-2014 15:06:50

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
set(handles.results, 'Visible', 'off');
set(handles.num_samples, 'Visible', 'off');

function populate_attribute_value(handles)
device = cellstr(get(handles.iio_devices, 'String'));
device = char(device(get(handles.iio_devices, 'Value')));

attribute = cellstr(get(handles.iio_attributes, 'String'));
attribute = char(attribute(get(handles.iio_attributes, 'Value')));

%TODO : This doesn't seem to work
[ret, rbuf] = iio_cmd_read(handles.iio_cmdsrv, 2048, 'read %s\n', [device ' ' attribute]);

if ret ~= -1
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


% --- Executes on button press in iio_capture.
function iio_capture_Callback(hObject, eventdata, handles)
% hObject    handle to iio_capture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
num_samples = str2num(get(handles.num_samples, 'String'));
device = get_device(handles);

%TODO : This doesn't seem to work
[ret, rbuf] = iio_cmd_sample(handles.iio_cmdsrv, device, num_samples, 2);
if(ret > 0)
    data = uint16(rbuf(1:2:end))*2^8 + uint16(rbuf(2:2:end));
    plot(data); grid;
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

num_samples = str2num(get(handles.num_samples, 'String'));
device = get_device(handles);

%TODO : This doesn't seem to work
[ret, rbuf] = iio_cmd_sample(handles.iio_cmdsrv, device, num_samples, 2);
if(ret > 0)
    data = uint16(rbuf(1:2:end))*2^8 + uint16(rbuf(2:2:end));
    assignin('base', 'IIO_Scope_Data', data);
end


% --- Executes on selection change in iio_devices.
function iio_devices_Callback(hObject, eventdata, handles)
% hObject    handle to iio_devices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
populate_attributes(handles);
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
