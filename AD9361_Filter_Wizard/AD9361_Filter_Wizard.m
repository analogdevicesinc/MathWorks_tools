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

function varargout = AD9361_Filter_Wizard(varargin)
% AD9361_FILTER_WIZARD MATLAB code for AD9361_Filter_Wizard.fig
%      AD9361_FILTER_WIZARD, by itself, creates a new AD9361_FILTER_WIZARD or raises the existing
%      singleton*.
%
%      H = AD9361_FILTER_WIZARD returns the handle to a new AD9361_FILTER_WIZARD or the handle to
%      the existing singleton*.
%
%      AD9361_FILTER_WIZARD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AD9361_FILTER_WIZARD.M with the given input arguments.
%
%      AD9361_FILTER_WIZARD('Property','Value',...) creates a new AD9361_FILTER_WIZARD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AD9361_Filter_Wizard_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AD9361_Filter_Wizard_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AD9361_Filter_Wizard

% Last Modified by GUIDE v2.5 11-Mar-2014 13:19:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @AD9361_Filter_Wizard_OpeningFcn, ...
    'gui_OutputFcn',  @AD9361_Filter_Wizard_OutputFcn, ...
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

% --- Executes just before AD9361_Filter_Wizard is made visible.
function AD9361_Filter_Wizard_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AD9361_Filter_Wizard (see VARARGIN)

% Choose default command line output for AD9361_Filter_Wizard
handles.output = hObject;

handles.Original_Size = get(handles.AD9361_Filter_app, 'Position');

handles.MAX_BBPLL_FREQ = 1430000000;                         % 1430.0 MHz
handles.MIN_BBPLL_FREQ =  715000000;                         %  715.0 MHz

handles.MAX_ADC_CLK    =  640000000;                         %  640.0 MHz
handles.MIN_ADC_CLK    =  handles.MIN_BBPLL_FREQ / (2 ^ 6);  %   11.2 MHz
handles.MAX_DAC_CLK    =  handles.MAX_ADC_CLK / 2;           % (MAX_ADC_CLK / 2)

handles.MAX_DATA_RATE  =   61440000;                         %   61.44 MSPS
handles.MIN_DATA_RATE  =  handles.MIN_BBPLL_FREQ / (48 * (2 ^ 6));

guidata(hObject, handles);

axes(handles.ADI_logo);
pict = imread('Analog_Devices_Logo.png');
image(pict);
axis image;
box off;
set(handles.ADI_logo, 'XTickLabel', []);
set(handles.ADI_logo, 'YTickLabel', []);
set(handles.ADI_logo, 'XTick', []);
set(handles.ADI_logo, 'YTick', []);
set(handles.ADI_logo, 'Box', 'off');
set(handles.ADI_logo, 'HandleVisibility', 'off');

axes(handles.magnitude_plot);

handles.iio_cmdsrv = {};
handles.taps = {};

reset_input(hObject, handles);
handles.clock_units = get(handles.Clock_units, 'Value');
handles.freq_units = get(handles.Freq_units, 'Value');
handles.active_plot = 0;

set(zoom(gca),'ActionPostCallback',@(x,y) zoom_axis(gca));

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AD9361_Filter_Wizard wait for user response (see UIRESUME)
% uiwait(handles.AD9361_Filter_app);

% --- Outputs from this function are returned to the command line.
function varargout = AD9361_Filter_Wizard_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in Freq_units.
function Freq_units_Callback(hObject, eventdata, handles)
% hObject    handle to Freq_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
units = get(hObject, 'Value');

if (handles.freq_units ~= units)
    fstop = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String')));
    fpass = value2Hz(handles, handles.freq_units, str2double(get(handles.Fpass, 'String')));
    
    handles.freq_units = units;
    set(handles.Fstop, 'String', num2str(Hz2value(handles, handles.freq_units, fstop)));
    set(handles.Fpass, 'String', num2str(Hz2value(handles, handles.freq_units, fpass)));
    % Update handles structure
    guidata(hObject, handles);
end


% Hints: contents = cellstr(get(hObject,'String')) returns Freq_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Freq_units


% --- Executes during object creation, after setting all properties.
function Freq_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Freq_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fpass_Callback(hObject, eventdata, handles)
% hObject    handle to Fpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)
% Hints: get(hObject,'String') returns contents of Fpass as text
%        str2double(get(hObject,'String')) returns contents of Fpass as a double


% --- Executes during object creation, after setting all properties.
function Fpass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fpass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Fstop_Callback(hObject, eventdata, handles)
% hObject    handle to Fstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if str2double(get(hObject,'String')) >= get_data_rate(handles) / 2
    set(hObject,'String', get_data_rate(handles)/2);
end

if str2double(get(hObject,'String')) <= str2double(get(handles.Fpass,'String'))
    set(hObject,'String', get(handles.Fpass,'String'));
end

handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)
% Hints: get(hObject,'String') returns contents of Fstop as text
%        str2double(get(hObject,'String')) returns contents of Fstop as a double


% --- Executes during object creation, after setting all properties.
function Fstop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Pll_rate_Callback(hObject, eventdata, handles)
% hObject    handle to Pll_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Pll_rate as text
%        str2double(get(hObject,'String')) returns contents of Pll_rate as a double
if (handles.active_plot ~= 0)
    handles.active_plot = 0;
end
plot_buttons_off(handles);

% --- Executes during object creation, after setting all properties.
function Pll_rate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Pll_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function converter_clk_Callback(hObject, eventdata, handles)
% hObject    handle to converter_clk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of converter_clk as text
%        str2double(get(hObject,'String')) returns contents of converter_clk as a double
if (handles.active_plot ~= 0)
    handles.active_plot = 0;
end
plot_buttons_off(handles);

% --- Executes during object creation, after setting all properties.
function converter_clk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to converter_clk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in Clock_units.
function Clock_units_Callback(hObject, eventdata, handles)
% hObject    handle to Clock_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
units = get(hObject, 'Value');

if (handles.clock_units ~= units)
    data_clk = value2Hz(handles, handles.clock_units, str2double(get(handles.data_clk, 'String')));
    converter_clk = value2Hz(handles, handles.clock_units, str2double(get(handles.converter_clk, 'String')));
    pll_clk = value2Hz(handles, handles.clock_units, str2double(get(handles.Pll_rate, 'String')));
    
    handles.clock_units = units;
    
    put_data_clk(handles, data_clk);
    set_converter_rate(handles, converter_clk);
    set_pll_rate(handles, pll_clk);
    
    % Update handles structure
    guidata(hObject, handles);
end
% Hints: contents = cellstr(get(hObject,'String')) returns Clock_units contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Clock_units


% --- Executes during object creation, after setting all properties.
function Clock_units_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Clock_units (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function interpolate = converter_interp(handles)
interpolate = cellstr(get(handles.converter2PLL, 'String'));
interpolate = char(interpolate(get(handles.converter2PLL, 'Value')));
interpolate = str2num(interpolate(1:2));

function interpolate = HB_interp(handles)
interpolate = cellstr(get(handles.HB2converter, 'String'));
interpolate = char(interpolate(get(handles.HB2converter, 'Value')));
interpolate = str2num(interpolate(1:2));

function interpolate = fir_interp(handles)
interpolate = cellstr(get(handles.FIR2HB, 'String'));
interpolate = char(interpolate(get(handles.FIR2HB, 'Value')));
interpolate = str2num(interpolate(1:2));

function fix_converter2pll(hObject, handles)

converter_rate = get_converter_clk(handles) * get(handles.DAC_by2, 'Value');

i = 1;
j = 0;
str = '';
% avalible interpolation factors base on dividers
while i <= 6 & (converter_rate * (2^i) <= handles.MAX_BBPLL_FREQ)
    if (converter_rate * (2^i) >= handles.MIN_BBPLL_FREQ)
        if j
            str = char(str, sprintf('%d x', 2 ^ i));
        else
            str = sprintf('%d x', 2 ^ i);
        end
        j = j + 1;
    end
    i = i + 1;
end
i = i - 1;

if get(handles.converter2PLL, 'Value') > j
    set(handles.converter2PLL, 'Value', j);
end
set(handles.converter2PLL, 'String', str);

pll_rate = converter_rate * converter_interp(handles);
set_pll_rate(handles, pll_rate);

% Update handles structure
guidata(hObject, handles);

function fix_FIR2HB(hObject, handles)
data_rate = get_data_rate(handles);
i = 1;
j = 0;
k = fir_interp(handles);
l = 0;
str = '';
tmp = [1 2 4];
while i <= (size(tmp, 2)) && (data_rate * tmp(i) <= 122.88 * 1e6)
    if (data_rate * tmp(i) >= handles.MIN_ADC_CLK / 12)
        if j
            str = char(str, sprintf('%d x', tmp(i)));
        else
            str = sprintf('%d x', tmp(i));
        end
        j = j + 1;
        if k == tmp(i)
            l = j;
        end
    end
    i = i + 1;
end

if l
    set(handles.FIR2HB, 'Value', l);
else
    set(handles.FIR2HB, 'Value', j);
end

set(handles.FIR2HB, 'String', str);


function fix_HB2converter(hObject, handles)

data_rate = get_data_rate(handles);

converter_rate = data_rate * HB_interp(handles) * fir_interp(handles);

if (get(handles.filter_type, 'Value') == 1)
    % receive
    max_rate = handles.MAX_ADC_CLK;
else
    %transmitt
    max_rate = handles.MAX_DAC_CLK;
end

if converter_rate >= max_rate
    while (converter_rate >= max_rate)
        set(handles.HB2converter, 'Value', get(handles.HB2converter, 'Value') - 1);
        converter_rate = data_rate * HB_interp(handles) * fir_interp(handles);;
    end
    set_converter_rate(handles, converter_rate);
end

i = 1;
j = 0;
k = HB_interp(handles);
l = 0;
str = '';
% avalible interpolation factors base on HB1/HB2/HB3
tmp = [1 2 3 4 6 8 12];
while i <= (size(tmp, 2)) && (data_rate * fir_interp(handles) * tmp(i) <= max_rate)
    if (data_rate * fir_interp(handles) * tmp(i) >= handles.MIN_ADC_CLK)
        if j
            str = char(str, sprintf('%d x', tmp(i)));
        else
            str = sprintf('%d x', tmp(i));
        end
        j = j + 1;
        if k == tmp(i)
            l = j;
        end
    end
    i = i + 1;
end

if l
    set(handles.HB2converter, 'Value', l);
else
    set(handles.HB2converter, 'Value', j);
end
set(handles.HB2converter, 'String', str);

pll_rate = data_rate * fir_interp(handles) * HB_interp(handles) * converter_interp(handles) * get(handles.DAC_by2, 'Value');

if (pll_rate < handles.MIN_BBPLL_FREQ)
    % Can we increase the Converter -> PLL dividor?
    x = log2(handles.MIN_BBPLL_FREQ / (data_rate * fir_interp(handles) * HB_interp(handles) * get(handles.DAC_by2, 'Value')));
    if round(x) > 6
        % Set to the max already, so we need to increase the interpolation rate.
        set(handles.HB2converter, 'Value', get(handles.HB2converter, 'Value') + 1);
        fix_converter2pll(hObject, handles)
    end
end

% Update handles structure
guidata(hObject, handles);

function data_clk_Callback(hObject, eventdata, handles)
% hObject    handle to data_clk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data_rate = get_data_rate(handles);

fstop = value2Hz(handles, get(handles.Freq_units, 'Value'), str2double(get(handles.Fstop, 'String')));

if data_rate / 2 <= fstop
    fstop = data_rate / 2;
    set(handles.Fstop, 'String', Hz2value(handles, get(handles.Freq_units, 'Value'),fstop));
    if value2Hz(handles, get(handles.Freq_units, 'Value'), str2double(get(handles.Fpass, 'String'))) >= fstop
        set(handles.Fpass, 'String', num2str(0.9 * Hz2value(handles, get(handles.Freq_units, 'Value'),fstop)));
    end
end

fix_FIR2HB(hObject, handles);
fix_HB2converter(hObject, handles);

converter_rate = data_rate * HB_interp(handles) * fir_interp(handles);
pll_rate = converter_rate * converter_interp(handles) * get(handles.DAC_by2, 'Value');

if (pll_rate < handles.MIN_BBPLL_FREQ)
    fix_converter2pll(hObject, handles);
end

put_data_clk(handles, data_rate);
set_converter_rate(handles, converter_rate);
set_pll_rate(handles, pll_rate);

fix_converter2pll(hObject, handles);

handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function data_clk_CreateFcn(hObject, eventdata, handles)
% hObject    handle to data_clk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Astop_Callback(hObject, eventdata, handles)
% hObject    handle to Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Astop as text
%        str2double(get(hObject,'String')) returns contents of Astop as a double
if get(handles.FIR_Astop, 'Value') >= str2double(get(hObject,'String'))
    set(handles.FIR_Astop, 'Value', str2double(get(hObject,'String')));
end
handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function Astop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Apass_Callback(hObject, eventdata, handles)
% hObject    handle to Apass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if str2double(get(hObject,'String')) == 0
    set(hObject,'String', '0.00001');
end

handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function Apass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Apass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filter_type.
function filter_type_Callback(hObject, eventdata, handles)
% hObject    handle to filter_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value') == 1
    set(handles.DAC_by2, 'Visible', 'off');
    set(handles.DAC_by2, 'Value', 1);
    set(handles.DAC_by2_label, 'Visible', 'off');
else
    set(handles.DAC_by2, 'Visible', 'on');
    set(handles.DAC_by2_label, 'Visible', 'on');
end
% Hints: contents = cellstr(get(hObject,'String')) returns filter_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filter_type


% --- Executes during object creation, after setting all properties.
function filter_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save2coeffienients.
function save2coeffienients_Callback(hObject, eventdata, handles)
% hObject    handle to save2coeffienients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,path] = uiputfile('*.ftr', 'Save coefficients as');
if filename == 0
    return;
else
    newpath = strcat(path,filename);
end

fid = fopen(newpath,'w');

fprintf(fid, '# Generated with the Matlab AD9361 filter wizard, version 4\n');
fprintf(fid, '%s\n', strcat('# Generated', 32, datestr(now())));
fprintf(fid, '# Inputs:\n');

data_rate = get_data_rate(handles);
converter_rate = get_converter_clk(handles);
pll_rate = get_pll_rate(handles);

fprintf(fid, '# PLL CLK frequecy = %f Hz\n', pll_rate);
fprintf(fid, '# Converter sample frequecy = %f Hz\n', converter_rate);
fprintf(fid, '# Data sample frequecy = %f Hz\n', data_rate);
if get(handles.filter_type, 'Value') == 1
    fprintf(fid, 'R');
else
    fprintf(fid, 'T');
end
fprintf(fid, 'X %d ', get(handles.FIR_1, 'Value') + (2 * get(handles.FIR_1, 'Value')));
% calculate the gain
s = ceil(sum(handles.taps)/2^15);
s = (s - 1) * -6;

if get(handles.filter_type, 'Value') == 1
    % Receive
    fprintf(fid, 'GAIN %d ', s);
    fprintf(fid, 'DEC %d\n', handles.int);
else
    % Transmit
    if handles.int == 2
        s = s+6;
    elseif handles.int == 4
        s = s+12;
    end
    fprintf(fid, 'GAIN %d ', s);
    fprintf(fid, 'INT %d\n', handles.int);
end

fclose(fid);

dlmwrite(newpath, handles.taps, '-append','delimiter', '\n','newline', 'pc');


% Hint: get(hObject,'Value') returns toggle state of save2coeffienients


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in save2target.
function save2target_Callback(hObject, eventdata, handles)
% hObject    handle to save2target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save2target



function IP_num_Callback(hObject, eventdata, handles)
% hObject    handle to IP_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of IP_num as text
%        str2double(get(hObject,'String')) returns contents of IP_num as a double


% --- Executes during object creation, after setting all properties.
function IP_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IP_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function FIR_Astop_Callback(hObject, eventdata, handles)
% hObject    handle to FIR_Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function FIR_Astop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FIR_Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in target_get_clock.
function target_get_clock_Callback(hObject, eventdata, handles)
% hObject    handle to target_get_clock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~ isempty(handles.iio_cmdsrv)
    [ret, rbuf] = iio_cmd_read(handles.iio_cmdsrv, 200, 'read ad9361-phy in_voltage_sampling_frequency\n');
    if(ret == -1)
        msgbox('Could not read clocks!', 'Error','error');
        return;
    end
    [ret, rbuf1] = iio_cmd_read(handles.iio_cmdsrv, 200, 'read ad9361-phy rx_path_rates\n');
    if(ret == -1)
        msgbox('Could not read clocks!', 'Error','error');
        return;
    end
    data_clk = str2num(rbuf);
    clocks = sscanf(rbuf1, 'BBPLL:%d ADC:%d');
    div_adc = num2str(clocks(2) / data_clk);
    interpolate = cellstr(get(handles.HB2converter, 'String'))';
    idx = find(strncmp(interpolate, div_adc, length(div_adc)) == 1);
    if(~isempty(idx))
        set(handles.HB2converter, 'Value', idx(1));
    end
    put_data_clk(handles, data_clk);
    data_clk_Callback(handles.data_clk, eventdata, handles);
end
% Hint: get(hObject,'Value') returns toggle state of target_get_clock


% --- Executes on button press in FVTool_deeper.
function FVTool_deeper_Callback(hObject, eventdata, handles)
% hObject    handle to FVTool_deeper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data_rate = get_data_rate(handles);
converter_rate = value2Hz(handles, handles.clock_units, str2double(get(handles.converter_clk, 'String')));
fstop = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String')));
fpass = value2Hz(handles, handles.freq_units, str2double(get(handles.Fpass, 'String')));

if (get(handles.filter_type, 'Value') == 1)
    Hanalog = handles.filters.Stage(1).Stage(1);
    Hmiddle = handles.filters.Stage(1);
    Hmd = handles.filters.Stage(2);
    tmp = 'Rx';
else
    Hanalog = handles.filters.Stage(2).Stage(end);
    Hmiddle = handles.filters.Stage(2);
    Hmd = handles.filters.Stage(1);
    tmp = 'Tx';
end

apass = str2double(get(handles.Apass, 'String'));
astop = str2double(get(handles.Astop, 'String'));


str = sprintf('%s Filter\nFpass = %g MHz; Fstop = %g MHz\nApass = %g dB; Astop = %g dB', tmp, fpass/1e6, fstop/1e6, apass, astop);

hfvt1 = fvtool(Hanalog,Hmiddle,handles.filters,...
    'FrequencyRange','Specify freq. vector', ...
    'FrequencyVector',linspace(0,converter_rate/2,2048),'Fs',...
    converter_rate, ...
    'ShowReference','off','Color','White');
set(hfvt1, 'Color', [1 1 1]);
set(hfvt1.CurrentAxes, 'YLim', [-100 20]);
legend(hfvt1, 'Analog Filter', 'Analog + Half Band','Analog + HB + FIR');
text(1, 10,...
    str,...
    'BackgroundColor','white',...
    'EdgeColor','red');

[gd,~] = grpdelay(handles.filters,1024);
I = round(fpass/(converter_rate/2)*1024);
gd2 = gd(1:I).*(1/converter_rate);
gd_diff = max(gd2)-min(gd2);
str2 = sprintf('Delay Variance = %g ns', gd_diff*1e9);

hfvt0 = fvtool(handles.filters,...
    'FrequencyRange','Specify freq. vector', ...
    'FrequencyVector',linspace(0,fpass,2048),...
    'Fs',converter_rate,'Analysis','grpdelay');
hfvt0.GroupDelayUnits = 'Time';
text(0.1,(mean(gd2))*1e6,...
    str2,...
    'BackgroundColor','white',...
    'EdgeColor','red');

hfvt2 = fvtool(...
    Hmd,...
    'FrequencyRange','Specify freq. vector', ...
    'FrequencyVector',linspace(0,data_rate/2,2048),'Fs',...
    data_rate*handles.int, ...
    'ShowReference','off','Color','White');
set(hfvt2.CurrentAxes, 'YLim', [-100 20]);
legend(hfvt2, 'FIR Filter');

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over FIR_Astop.
function FIR_Astop_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FIR_Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function zoom_axis(ax)
A = get(ax, 'XTick') / 1e6;
arrayfun(@num2str, A, 'unif', 0);
set(ax, 'XTickLabel', A);

function plot_buttons_off(handles)
set(handles.FVTool_deeper, 'Visible', 'off');
set(handles.FVTool_datarate, 'Visible', 'off');
set(handles.save2coeffienients, 'Visible', 'off');
set(handles.save2target, 'Visible', 'off');
set(handles.save2workspace, 'Visible', 'off');
set(handles.save2HDL, 'Visible', 'off');

set(handles.results_Apass, 'Visible', 'off');
set(handles.results_Astop, 'Visible', 'off');
set(handles.results_taps, 'Visible', 'off');
set(handles.results_group_delay, 'Visible', 'off');


function create_filter(hObject, handles)

v = version('-release');
v = str2num(v(1:4));
if (v < 2012)
    choice = questdlg('Sorry. The AD9361/AD9364 Filter Design Wizard requires at least the R2012 version of MATLAB. You do not seem to have it installed.', ...
        'Error Message', ...
        'More Information','OK','OK');
    switch choice
        case 'More Information'
            web('http://www.mathworks.com/products/matlab/');
        case 'OK'
    end
    return
end

if ~ license('test','signal_blocks') || ~ license('checkout','signal_blocks')
    choice = questdlg('Sorry. The AD9361/AD9364 Filter Design Wizard requires the DSP System Toolbox. You do not seem to have it installed.', ...
        'Error Message', ...
        'More Information','OK','OK');
    switch choice
        case 'More Information'
            web('http://www.mathworks.com/products/dsp-system/');
        case 'OK'
    end
    return
end

set(handles.design_filter, 'Visible', 'off');

fstop = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String')));
fpass = value2Hz(handles, handles.freq_units, str2double(get(handles.Fpass, 'String')));

apass = str2double(get(handles.Apass, 'String'));
astop = str2double(get(handles.Astop, 'String'));
dbstop_min = get(handles.FIR_Astop, 'Value');

data_rate = get_data_rate(handles);
FIR_interp = fir_interp(handles);
HB_interp = HB_interp(handles);
PLL_mult = converter_interp(handles) * get(handles.DAC_by2, 'Value');

if get(handles.Advanced_options, 'Value') && get(handles.phase_eq, 'Value')
    Ph_eq = str2double(get(handles.target_delay, 'String'));
else
    Ph_eq = -1;
end

wnom = value2Hz(handles, handles.clock_units, str2double(get(handles.Fcutoff, 'String')));

Use_9361 = get(handles.Use_FIR, 'Value');


plot_buttons_off(handles);

% make sure things are sane before drawing
if fpass >= fstop || fpass <= 0 || fstop <= 0
    display_default_image(hObject, handles);
    plot_buttons_off(handles);
    handles.active_plot = 0;
    set(handles.design_filter, 'Visible', 'on');
    guidata(hObject, handles);
    return;
end

drawnow;

if (get(handles.filter_type, 'Value') == 1)
    [rfirtaps,rxFilters,dBripple_actual,dBstop_max,delay,webinar] = internal_designrxfilters9361_fixed(...
        data_rate, FIR_interp, HB_interp, PLL_mult, fpass, fstop, apass, astop, dbstop_min, Ph_eq, Use_9361, wnom);
    handles.filters = rxFilters;
    handles.taps = rfirtaps;
else
    DAC_mult = get(handles.DAC_by2, 'Value');
    [tfirtaps,txFilters,dBripple_actual,dBstop_max,delay,webinar] = internal_designtxfilters9361_fixed(...
        data_rate, FIR_interp, HB_interp, DAC_mult, PLL_mult, fpass, fstop, apass, astop, dbstop_min, Ph_eq, Use_9361, wnom);
    handles.filters = txFilters;
    handles.taps = tfirtaps;
end

handles.int = FIR_interp;
if (str2double(get(handles.target_delay, 'String'))) == 0
    set(handles.target_delay, 'String', num2str(delay * 1e9, 4));
end

handles.simrfmodel = webinar;

set(handles.FVTool_deeper, 'Visible', 'on');
set(handles.FVTool_datarate, 'Visible', 'on');

units = cellstr(get(handles.Clock_units, 'String'));
units = char(units(get(handles.Clock_units, 'Value')));
set(handles.FVTool_datarate, 'String', sprintf('Launch FVTool to %g %s', str2double(get(handles.data_clk, 'String'))/2, units));

set(handles.save2coeffienients, 'Visible', 'on');
if ~ isempty(handles.iio_cmdsrv)
    set(handles.save2target, 'Visible', 'on');
end
set(handles.save2workspace, 'Visible', 'on');
if ~ get(handles.Use_FIR, 'Value')
    set(handles.save2HDL, 'Visible', 'on');
end

set(handles.results_Apass, 'Visible', 'on');
set(handles.results_Astop, 'Visible', 'on');
set(handles.results_taps, 'Visible', 'on');
set(handles.results_group_delay, 'Visible', 'on');

set(handles.results_taps, 'String', [num2str(length(handles.taps)) ' ']);

converter_rate = data_rate * FIR_interp * HB_interp;

G = 8192;
% if this is a new plot, make a new plot, if we are just tweaking
% things, then redraw in the same zoom window.
if handles.active_plot == 0
    clf(handles.magnitude_plot);
    handles.active_plot = plot(linspace(0,data_rate/2,G),mag2db(abs(freqz(handles.filters,linspace(0,data_rate/2,G),converter_rate))));
    xlim([0 data_rate/2]);
    ylim([-100 10]);
    zoom_axis(gca);
    xlabel('Frequency (MHz)');
    ylabel('Magnitude (dB)');
    
    % plot the mask that we are interested in
    line([fpass fpass], [-(apass/2) -100], 'Color', 'Red');
    line([0 fpass], [-(apass/2) -(apass/2)], 'Color', 'Red');
    line([0 fstop], [apass/2 apass/2], 'Color', 'Red');
    line([fstop fstop], [apass/2 -astop], 'Color', 'Red');
    line([fstop data_rate], [-astop -astop], 'Color', 'Red');
else
    set(handles.active_plot,'ydata',mag2db(abs(freqz(handles.filters,linspace(0,data_rate/2,G),converter_rate))),'xdata',linspace(0,data_rate/2,G));
end

% add the quantitative values about actual passband, stopband, and group
% delay
[gd,~] = grpdelay(handles.filters,1024);
I = round(fpass/(converter_rate/2)*1024);
gd2 = gd(1:I).*(1/converter_rate);
gd_diff = max(gd2)-min(gd2);

set(handles.results_Astop, 'String', [num2str(dBstop_max) ' dB ']);
set(handles.results_Apass, 'String', [num2str(dBripple_actual) ' dB ']);
set(handles.results_group_delay, 'String', [num2str(gd_diff * 1e9, 3) ' ns ']);

if get(handles.filter_type, 'Value') == 1
    i = 2;
else
    i = 1;
end

if strcmp(handles.filters.Stage(i).Arithmetic, 'double')
    set(handles.results_fixed, 'String', 'Floating point approx');
else
    set(handles.results_fixed, 'String', 'Fixed Point');
end
set(handles.design_filter, 'Visible', 'on');
guidata(hObject, handles);


function reset_input(hObject, handles)
handles.active_plot = 0;
display_default_image(hObject, handles);

options = load('ad9361_settings.mat');

Tx = strcat('Tx_', fieldnames(options.ad9361_settings.tx));
Rx = strcat('Rx_', fieldnames(options.ad9361_settings.rx));
choices  = cat(1, Rx, Tx);

[selection,ok] = listdlg('PromptString','Please Select a Profile:',...
    'SelectionMode','single',...
    'OKString', 'Select', ...
    'ListSize', [150 150], ...
    'ListString', choices);

if ~ ok
    selection = 1;
end

%                               Rx           Tx
% FIR = [1 2 4];                0.23|61.44        61.44
% HB1 = [1 2];                  0.93|122.88       122.88
% HB2 = [1 2];                  1.86|245.76       160
% HB3 = [1 2 3];                3.72|320          320
% converter                    11.2 |640          5.58|320
% DAC_by2 [1 2]                                   11.2|640
% PLL = [1 2 4 8 16 32 64];     715|1430          715|1430

if strcmp(choices{selection}(1:2), 'Rx')
    set(handles.filter_type, 'Value', 1);
    sel = getfield(options.ad9361_settings.rx, Rx{selection}(4:end));
    set(handles.DAC_by2, 'Visible', 'off');
    set(handles.DAC_by2_label, 'Visible', 'off');
    set(handles.DAC_by2, 'Value', 1);
else
    set(handles.filter_type, 'Value', 2);
    sel = getfield(options.ad9361_settings.tx, Tx{selection - length(Rx)}(4:end));
    set(handles.DAC_by2, 'Visible', 'on');
    set(handles.DAC_by2_label, 'Visible', 'on');
    set(handles.DAC_by2, 'Value', sel.DAC_div);
end

% Set the defaults
set(handles.Advanced_options, 'Value', 0);
set(handles.Use_FIR, 'Value', 1);
set(handles.FIR_1, 'Value', 1);
set(handles.FIR_2, 'Value', 1);

% File is in MHz
handles.freq_units = 3;
set(handles.Freq_units, 'Value', handles.freq_units);
handles.clock_units = 3;
set(handles.Clock_units, 'Value', handles.clock_units);

% set things from the file.
if sel.phEQ == -1
    set(handles.phase_eq, 'Value', 0);
else
    set(handles.Advanced_options, 'Value', 1);
    set(handles.phase_eq, 'Value', 1);
    set(handles.target_delay, 'Value', num2str(sel.phEQ));
end

set(handles.Fpass, 'String', num2str(sel.Fpass));
set(handles.Fstop, 'String', num2str(sel.Fstop));
set(handles.Apass, 'String', num2str(sel.dBripple));
set(handles.Astop, 'String', num2str(sel.dBstop));

if sel.Rdata > handles.MAX_DATA_RATE / 1e6
    sel.Rdata = handles.MAX_DATA_RATE / 1e6;
end
if sel.Rdata < handles.MIN_DATA_RATE / 1e6
    sel.Rdata = handles.MIN_DATA_RATE / 1e6
end

set(handles.data_clk, 'String', num2str(sel.Rdata));

% make sure it's not too small
if sel.Rdata * 12 < (handles.MIN_ADC_CLK / 1e6)
    fir = [4];
elseif sel.Rdata * 6 < (handles.MIN_ADC_CLK / 1e6)
    fir = [2 4];
else
    fir = [1 2 4];
end

% make sure it's not too big
% Fastest the FIR can run is 122.88 MSPS
for i = 1:length(fir)
    if sel.Rdata * fir(i) > 122.88
        fir(i) = 1;
    end
end
fir = unique(sort(fir));

tmp = {};
j = 1;
for i = 1:length(fir)
    tmp = [tmp, sprintf('%i x', fir(i))];
    if sel.FIR_interp == fir(i)
        j = i;
    end
end
set(handles.FIR2HB, 'String', tmp);
set(handles.FIR2HB, 'Value', j);


hb_min = [1 2 3 4 6 8 12];
% make sure it's not too small
for i = 1:length(hb_min)
    if sel.Rdata * sel.FIR_interp * hb_min(i) <= (handles.MIN_ADC_CLK / 1e6)
        hb_min(i) = 0;
    end
end
hb_min = unique(sort(hb_min));
while hb_min(1) == 0
    hb_min = hb_min(2:end);
end

tmp = {};
j = 1;
for i = 1:length(hb_min)
    tmp = [tmp, sprintf('%i x', hb_min(i))];
    if sel.HB_interp == hb_min(i)
        j = i;
    end
end
set(handles.HB2converter, 'String', tmp);
set(handles.HB2converter, 'Value', j);

converter = sel.Rdata * sel.FIR_interp * sel.HB_interp;

set_converter_rate(handles, converter * 1e6);

fix_converter2pll(hObject, handles);

% This **must** be set **after** the PLL clock is set properly
if sel.caldiv
    set(handles.Advanced_options, 'Value', 1);
    set_caldiv(handles, sel.caldiv);
end

units = cellstr(get(handles.Clock_units, 'String'));
units = char(units(get(handles.Clock_units, 'Value')));
set(handles.FVTool_datarate, 'String', sprintf('Launch FVTool to %g %s', str2double(get(handles.data_clk, 'String'))/2, units));

% don't have data - so don't display the FVTool button
set(handles.FVTool_deeper, 'Visible', 'off');
set(handles.FVTool_datarate, 'Visible', 'off');

set(handles.save2coeffienients, 'Visible', 'off');
set(handles.save2target, 'Visible', 'off');
set(handles.save2workspace, 'Visible', 'off');
set(handles.save2HDL, 'Visible', 'off');

set(handles.target_get_clock, 'Visible', 'off');

if get(handles.Advanced_options, 'Value')
    show_advanced(handles);
else
    hide_advanced(handles);
end

guidata(hObject, handles);

% --------------------------------------------------------------------
function new_tooltip_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to new_tooltip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

reset_input(hObject, handles);
handles.clock_units = get(handles.Clock_units, 'Value');
handles.freq_units = get(handles.Freq_units, 'Value');
handles.active_plot = 0;

guidata(hObject, handles);


function display_default_image(hObject, handles)
set(handles.FVTool_deeper, 'Visible', 'off');
axes(handles.magnitude_plot);

max_y = 20;
ripple = 10;
Fpass = 90;
Fstop = 110;
label_colour = 'Red';

plot([Fstop Fstop], [ripple -80], 'Color', 'Black');

box on;
axis on;

%xlabel('Frequency');
set(gca,'XTickLabel',{});
xlim([0 200]);
text(-10, 0, '0dB');

ylabel('Mag (dB)');
set(gca,'YTickLabel',{});
ylim([-100 max_y]);

% Pass band
line([0 Fpass], [-ripple -ripple], 'Color', 'Black');
line([Fpass Fstop+30], [-ripple -ripple], 'Color', label_colour, 'LineStyle', ':');
line([0 Fstop], [ripple ripple], 'Color', 'Black');
line([Fstop Fstop+30], [ripple ripple], 'Color', label_colour, 'LineStyle', ':');
line([0 Fstop], [0 0], 'Color', label_colour, 'LineStyle', ':');

[x1, y1] = xy2norm(130, ripple);
[x2, y2] = xy2norm(130, max_y);
a = annotation('arrow', 'Y',[y2 y1], 'X',[x1 x2]);
set(a, 'Color', label_colour);
[x1, y1] = xy2norm(130, -ripple);
[x2, y2] = xy2norm(130, -max_y);
a = annotation('arrow', 'Y',[y2 y1], 'X',[x1 x2]);
set(a, 'Color', label_colour);
text(Fstop + 12, 0, 'A_{pass}', 'BackgroundColor','white', 'EdgeColor','white');

% Stop band
line([Fstop 200], [-80 -80], 'Color', 'Black');
line([Fpass Fpass], [-ripple -100], 'Color', 'Black');
line([Fstop Fstop], [-80 -100], 'Color', label_colour, 'LineStyle', ':');

line([150 170], [0 0], 'Color', label_colour, 'LineStyle', ':');
text(Fpass - 5, -105, 'F_{pass}');
text(Fstop - 5, -105, 'F_{stop}');
text(195, -105, 'Fs_{/2}');

% Arrows
w = 185;
[x1, y1] = xy2norm(w, 0);
[x2, y2] = xy2norm(w, -35);
a = annotation('arrow', 'Y',[y2 y1], 'X',[x1 x2]);
set(a, 'Color', label_colour);
[x1, y1] = xy2norm(w, -80);
[x2, y2] = xy2norm(w, -45);
a = annotation('arrow', 'Y',[y2 y1], 'X',[x1 x2]);
set(a, 'Color', label_colour);
text(150, -40, 'A_{stop}');

guidata(hObject, handles);

function [x1, y1] = xy2norm(x, y)
y_limits = get(gca, 'ylim');
x_limits = get(gca, 'xlim');
% Position = [left bottom width height]
axesoffsets = get(get(gcf, 'CurrentAxes'), 'Position');
Figure_Size = get(gcf, 'Position');
y1 = axesoffsets(2) / Figure_Size(4);
y2 = axesoffsets(4) / Figure_Size(4);
y3 = abs((y - y_limits(1)) / abs(y_limits(2) - y_limits(1)));
y1 = y1 + y2 * y3;
x1 = axesoffsets(1) / Figure_Size(4) + ...
    axesoffsets(2)/Figure_Size(4) * abs((x - x_limits(1)) / abs(x_limits(2) - x_limits(1)));


% --------------------------------------------------------------------
function save_filter_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filename = uiputfile('*.txt', 'Save filter setup as');
if filename == 0
    return;
end

fp = fopen(filename, 'wt');
fprintf(fp, 'Filter = %d\n', get(handles.filter_type, 'Value'));
fprintf(fp, 'Phase Equalization = %d\n', get(handles.phase_eq, 'Value'));
fprintf(fp, 'Use AD936x FIR = %d\n', get(handles.Use_FIR, 'Value'));

fstop = str2double(get(handles.Fstop, 'String'));
fpass = str2double(get(handles.Fpass, 'String'));
if (handles.freq_units == 2)
    fstop = fstop * 1e6;
    fpass = fpass * 1e6;
end
fprintf(fp, 'Fpass = %d\n', fpass);
fprintf(fp, 'Fstop = %d\n', fstop);
fprintf(fp, 'Apass = %d\n', str2double(get(handles.Apass, 'String')));
fprintf(fp, 'Astop = %d\n', str2double(get(handles.Astop, 'String')));
fprintf(fp, 'Param = %f\n', get(handles.FIR_Astop, 'Value'));

pll_rate = str2double(get(handles.Pll_rate, 'String'));
converter_rate = str2double(get(handles.converter_clk, 'String'));
data_rate = str2double(get(handles.data_clk, 'String'));
if (handles.clock_units == 2)
    pll_rate = pll_rate * 1e6;
    converter_rate = converter_rate * 1e6;
    data_rate = data_rate * 1e6;
end

fprintf(fp, 'PLL rate  = %d\n', pll_rate);
fprintf(fp, 'Converter = %d\n', converter_rate);
fprintf(fp, 'Data rate = %d\n', data_rate);

fclose(fp);


% --------------------------------------------------------------------
function open_filter_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to open_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = uigetfile('*.txt', 'Open Filter as');
if filename == 0
    return;
end
%t = fgets(fp);

reset_input(hObject, handles);

fp = fopen(filename, 'rt');

set(handles.filter_type, 'Value', fscanf(fp, 'Filter = %d\n'));
set(handles.phase_eq, 'Value', fscanf(fp, 'Phase Equalization = %d\n'));
set(handles.Use_FIR, 'Value', fscanf(fp, 'Use AD936x FIR = %d\n'));

handles.freq_units = 3;
set(handles.Freq_units, 'Value', handles.freq_units);
set(handles.Fpass, 'String', num2str((fscanf(fp, 'Fpass = %d\n') / 1e6)));
set(handles.Fstop, 'String', num2str((fscanf(fp, 'Fstop = %d\n') / 1e6)));
set(handles.Apass, 'String', num2str((fscanf(fp, 'Apass = %e\n'))));
set(handles.Astop, 'String', num2str((fscanf(fp, 'stop = %e\n'))));
set(handles.FIR_Astop, 'Value', fscanf(fp, 'Param = %f\n'));
handles.clock_units = 3;
set(handles.Clock_units, 'Value', handles.clock_units);
set(handles.Pll_rate, 'String', num2str((fscanf(fp, 'LL rate = %d\n') / 1e6)));
set(handles.converter_clk, 'String', num2str((fscanf(fp, 'Converter = %d\n') / 1e6)));
set(handles.data_clk, 'String', num2str((fscanf(fp, 'Data rate = %d\n') / 1e6)));

fclose(fp);
guidata(hObject, handles);


% --- Executes when AD9361_Filter_app is resized.
function AD9361_Filter_app_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to AD9361_Filter_app (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Figure_Size = get(hObject, 'Position');

x_pos = 1;
y_pos = 2;
width = 3;
height = 4;

if ~exist('handles', 'var')
    return;
end

if ~isfield(handles, 'Original_Size')
    return;
end

if (Figure_Size(width) < handles.Original_Size(width)) || (Figure_Size(height) < handles.Original_Size(height))
    set(hObject, 'Position', handles.Original_Size);
    Figure_Size = handles.Original_Size;
end

pos_mag = get(handles.magnitude_plot,'Position');
pos_cont = get(handles.controls,'Position');
pos_logo = get(handles.ADI_logo, 'Position');
pos_title = get(handles.title, 'Position');
pos_help = get(handles.help_button, 'Position');
pos_deeper = get(handles.FVTool_deeper, 'Position');

% 7 from the top
pos_mag(height) = Figure_Size(height) - pos_cont(height) - 7;
% 10 on each side
pos_mag(width) = Figure_Size(width) - 20;
%pos_mag(y_pos) = 10;
set(handles.magnitude_plot, 'Position', pos_mag);

pos_cont(x_pos) = (Figure_Size(width) - pos_cont(width))/2;
set(handles.controls,'Position', pos_cont);

pos_logo(y_pos) = Figure_Size(height) - pos_logo(height) - .5 ;
set(handles.ADI_logo, 'Position', pos_logo);

pos_title(x_pos) = (Figure_Size(width) - pos_title(width))/2;
pos_title(y_pos) = Figure_Size(height) - pos_title(height) - 1 ;
set(handles.title, 'Position', pos_title);

pos_help(x_pos) = Figure_Size(width) - pos_help(width) - 2;
pos_help(y_pos) = Figure_Size(height) - pos_help(height) - 1 ;
set(handles.help_button, 'Position', pos_help);

pos_deeper(x_pos) = Figure_Size(width) - pos_deeper(width) - 10;
pos_deeper(y_pos) = Figure_Size(height) - pos_deeper(height) - 6;
set(handles.FVTool_deeper, 'Position', pos_deeper);

guidata(hObject, handles);
movegui(hObject, 'onscreen');


% --- Executes on button press in phase_eq.
function phase_eq_Callback(hObject, eventdata, handles)
% hObject    handle to phase_eq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.target_delay_label, 'Visible', 'on');
    set(handles.target_delay, 'Visible', 'on');
    set(handles.target_delay, 'String', '0');
    set(handles.target_delay_units, 'Visible', 'on');
else
    set(handles.target_delay_label, 'Visible', 'off');
    set(handles.target_delay, 'Visible', 'off');
    set(handles.target_delay_units, 'Visible', 'off');
    set(handles.target_delay, 'String', '-1');
end

if (handles.active_plot ~= 0)
    handles.active_plot = 0;
end
plot_buttons_off(handles);
% Hint: get(hObject,'Value') returns toggle state of phase_eq


% --- Executes on button press in Use_FIR.
function Use_FIR_Callback(hObject, eventdata, handles)
% hObject    handle to Use_FIR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.active_plot ~= 0)
    handles.active_plot = 0;
end
plot_buttons_off(handles);
% Hint: get(hObject,'Value') returns toggle state of Use_FIR


% --- Executes on button press in save2workspace.
function save2workspace_Callback(hObject, eventdata, handles)
% hObject    handle to save2workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.filter_type, 'Value') == 1
    assignin('base', 'AD9361_Rx_Filter_object', handles.filters);
    assignin('base', 'FMCOMMS2_RX_Model_init', handles.simrfmodel);
else
    assignin('base', 'AD9361_Tx_Filter_object', handles.filters);
    assignin('base', 'FMCOMMS2_TX_Model_init', handles.simrfmodel);
end

% Hint: get(hObject,'Value') returns toggle state of save2workspace

% --- Executes on selection change in HB2converter.
function HB2converter_Callback(hObject, eventdata, handles)
% hObject    handle to HB2converter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fix_HB2converter(hObject, handles);
data_rate = get_data_rate(handles);

converter_rate = data_rate * HB_interp(handles) * fir_interp(handles);
set_converter_rate(handles, converter_rate);

fix_converter2pll(hObject, handles);

% Update handles structure
guidata(hObject, handles);

if (handles.active_plot ~= 0)
    handles.active_plot = 0;
end
plot_buttons_off(handles);

% Hints: contents = cellstr(get(hObject,'String')) returns HB2converter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HB2converter


% --- Executes during object creation, after setting all properties.
function HB2converter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HB2converter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in converter2PLL.
function converter2PLL_Callback(hObject, eventdata, handles)
% hObject    handle to converter2PLL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fix_converter2pll(hObject, handles);

converter_rate = get_converter_clk(handles);

pll_rate = converter_rate * converter_interp(handles) * get(handles.DAC_by2, 'Value');

set_pll_rate(handles, pll_rate);

% Update handles structure
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns converter2PLL contents as cell array
%        contents{get(hObject,'Value')} returns selected item from converter2PLL


% --- Executes during object creation, after setting all properties.
function converter2PLL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to converter2PLL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in help_button.
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('http://wiki.analog.com/resources/eval/user-guides/ad-fmcomms2-ebz/software/filters');
% Hint: get(hObject,'Value') returns toggle state of help_button


% --- Executes on button press in save2HDL.
function save2HDL_Callback(hObject, eventdata, handles)
% hObject    handle to save2HDL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~ license('test','fixed_point_toolbox') || ~ license('checkout','fixed_point_toolbox')
    choice = questdlg('Sorry. Generating HDL requires the Fixed-Point Designer. You do not seem to have it installed.', ...
        'Error Message', ...
        'More Information','OK','OK');
    switch choice
        case 'More Information'
            web('http://www.mathworks.com/products/fixed-point-designer/');
        case 'OK'
    end
    return
    
end

if get(handles.filter_type, 'Value') == 1
    Hd = handles.filters.Stage(2);
else
    Hd = handles.filters.Stage(1);
end
Hd.arithmetic='fixed';
fdhdltool(Hd);

% Hint: get(hObject,'Value') returns toggle state of save2HDL


% --- Executes on button press in FIR_1.
function FIR_1_Callback(hObject, eventdata, handles)
% hObject    handle to FIR_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FIR_1


% --- Executes on button press in FIR_2.
function FIR_2_Callback(hObject, eventdata, handles)
% hObject    handle to FIR_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FIR_2


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over HB2converter.
function HB2converter_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to HB2converter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function ret = value2Hz(handles, pulldown, value)
switch pulldown
    case 1
        ret = value;
    case 2
        ret = value * 1e3;
    case 3
        ret = value * 1e6;
end

function ret = Hz2value(handles, pulldown, value)
switch pulldown
    case 1
        ret = value;
    case 2
        ret = value / 1e3;
    case 3
        ret = value / 1e6;
end

function put_data_clk(handles, data_clk)
data_clk = Hz2value(handles, get(handles.Clock_units, 'Value'), data_clk);
set(handles.data_clk, 'String', num2str(data_clk, '%g'));

function data_clk = get_data_rate(handles)

data_rate = str2double(get(handles.data_clk, 'String'));
if isnan(data_rate)
    data_rate = str2num(get(handles.data_clk, 'String'));
end

data_rate = value2Hz(handles, get(handles.Clock_units, 'Value'), data_rate);

if data_rate <= handles.MIN_DATA_RATE
    data_rate = handles.MIN_DATA_RATE;
end
if data_rate >= handles.MAX_DATA_RATE
    data_rate = handles.MAX_DATA_RATE;
end

put_data_clk(handles, data_rate);
data_clk = data_rate;

function caldiv = get_caldiv(handles)

Fcutoff = str2double(get(handles.Fcutoff, 'String'));

if Fcutoff == 0
    wnom = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String')));
    if get(handles.filter_type, 'Value') == 1
        wnom = 1.4 * wnom;  % Rx
    else
        wnom = 1.6 * wnom;  % Tx
    end
else
    wnom = value2Hz(handles, handles.freq_units, Fcutoff);
end

div = ceil((get_pll_rate(handles)/wnom)*(log(2)/(2*pi)));
caldiv = min(max(div,3),511);

function set_caldiv(handles, value)
wc = (get_pll_rate(handles) / value)*(log(2)/(2*pi));
set(handles.Fcutoff, 'String', num2str(Hz2value(handles, handles.clock_units, wc)));

function converter_clk = get_converter_clk(handles)
converter_clk = str2double(get(handles.converter_clk, 'String'));
converter_clk = value2Hz(handles, get(handles.Clock_units, 'Value'), converter_clk);

function set_converter_rate(handles, value)
set(handles.converter_clk, 'String', [num2str(Hz2value(handles, get(handles.Clock_units, 'Value'), value)) ' ']);

function set_pll_rate(handles, value)
set(handles.Pll_rate, 'String', [num2str(Hz2value(handles, get(handles.Clock_units, 'Value'), value)) ' ']);
if str2double(get(handles.Fcutoff, 'String')) ~= 0
    set_caldiv(handles, get_caldiv(handles));
end

function pll = get_pll_rate(handles)
pll = value2Hz(handles, handles.clock_units, str2double(get(handles.Pll_rate, 'String')));

function Fcutoff_Callback(hObject, eventdata, handles)
% hObject    handle to Fcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set_caldiv(handles, get_caldiv(handles));
handles.active_plot = 0;
plot_buttons_off(handles);
guidata(hObject, handles)
% Hints: get(hObject,'String') returns contents of Fcutoff as text
%        str2double(get(hObject,'String')) returns contents of Fcutoff as a double


% --- Executes during object creation, after setting all properties.
function Fcutoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fcutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function target_delay_Callback(hObject, eventdata, handles)
% hObject    handle to target_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%set(handles.target_delay, 'String', num2str(handles.actualdelay));

% Hints: get(hObject,'String') returns contents of target_delay as text
%        str2double(get(hObject,'String')) returns contents of target_delay as a double


% --- Executes during object creation, after setting all properties.
function target_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to target_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to FIR_Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FIR_Astop as text
%        str2double(get(hObject,'String')) returns contents of FIR_Astop as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FIR_Astop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in FVTool_datarate.
function FVTool_datarate_Callback(hObject, eventdata, handles)
% hObject    handle to FVTool_datarate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data_rate = get_data_rate(handles);
converter_rate = value2Hz(handles, handles.clock_units, str2double(get(handles.converter_clk, 'String')));
fstop = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String')));
fpass = value2Hz(handles, handles.freq_units, str2double(get(handles.Fpass, 'String')));
apass = str2double(get(handles.Apass, 'String'));
astop = str2double(get(handles.Astop, 'String'));

if (get(handles.filter_type, 'Value') == 1)
    Hanalog = handles.filters.Stage(1).Stage(1);
    Hmiddle = handles.filters.Stage(1);
    Hmd = handles.filters.Stage(2);
    tmp = 'Rx';
else
    Hanalog = handles.filters.Stage(2).Stage(end);
    Hmiddle = handles.filters.Stage(2);
    Hmd = handles.filters.Stage(1);
    tmp = 'Tx';
end

str = sprintf('%s Filter\nFpass = %g MHz; Fstop = %g MHz\nApass = %g dB; Astop = %g dB', tmp, fpass/1e6, fstop/1e6, apass, astop);

hfvt3 = fvtool(Hanalog,Hmiddle,handles.filters,...
    'FrequencyRange','Specify freq. vector', ...
    'FrequencyVector',linspace(0,data_rate/2,2048),'Fs',...
    converter_rate, ...
    'ShowReference','off','Color','White');
set(hfvt3, 'Color', [1 1 1]);
set(hfvt3.CurrentAxes, 'YLim', [-100 20]);
legend(hfvt3, 'Analog Filter', 'Analog + Half Band','Analog + HB + FIR');
text(0.5, 10,...
    str,...
    'BackgroundColor','white',...
    'EdgeColor','red');

hfvt4 = fvtool(...
    Hmd,...
    'FrequencyRange','Specify freq. vector', ...
    'FrequencyVector',linspace(0,data_rate/2,2048),'Fs',...
    data_rate*handles.int, ...
    'ShowReference','off','Color','White');
set(hfvt4.CurrentAxes, 'YLim', [-100 20]);
legend(hfvt4, 'FIR Filter');

function show_advanced(handles)
set(handles.phase_eq, 'Visible', 'on');
if get(handles.phase_eq, 'Value')
    set(handles.target_delay_label, 'Visible', 'on');
    set(handles.target_delay, 'Visible', 'on');
    set(handles.target_delay_units, 'Visible', 'on');
end
set(handles.Fcutoff_label, 'Visible', 'on');
set(handles.Fcutoff, 'Visible', 'on');
set(handles.Use_FIR, 'Visible', 'on');
set(handles.FIR_Astop, 'Visible', 'on');
set(handles.FIR_Astop_label, 'Visible', 'on');

if ~ str2double(get(handles.Fcutoff, 'String'))
    set_caldiv(handles, get_caldiv(handles));
end

function hide_advanced(handles)
set(handles.phase_eq, 'Value', 0);
set(handles.Use_FIR, 'Value', 1);
set(handles.target_delay, 'String', '0');
set(handles.Fcutoff, 'String', '0');

set(handles.phase_eq, 'Visible', 'off');
set(handles.target_delay_label, 'Visible', 'off');
set(handles.target_delay, 'Visible', 'off');
set(handles.target_delay_units, 'Visible', 'off');
set(handles.Fcutoff_label, 'Visible', 'off');
set(handles.Fcutoff, 'Visible', 'off');
set(handles.Use_FIR, 'Visible', 'off');
set(handles.FIR_Astop, 'Visible', 'off');
set(handles.FIR_Astop_label, 'Visible', 'off');

% --- Executes on button press in Advanced_options.
function Advanced_options_Callback(hObject, eventdata, handles)
% hObject    handle to Advanced_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    show_advanced(handles)
else
    hide_advanced(handles)
end
% Hint: get(hObject,'Value') returns toggle state of Advanced_options

% --------------------------------------------------------------------
function save_filter2workspace_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to save_filter2workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter.Rdata = get_data_rate(handles)/1e6;
filter.Fpass = value2Hz(handles, handles.freq_units, str2double(get(handles.Fpass, 'String'))) / 1e6;
filter.Fstop = value2Hz(handles, handles.freq_units, str2double(get(handles.Fstop, 'String'))) / 1e6;
if get(handles.Advanced_options, 'Value')
    filter.caldiv = get_caldiv(handles);
end
filter.FIR_interp = fir_interp(handles);
filter.HB_interp = HB_interp(handles);
filter.PLL_mult = converter_interp(handles);
filter.dBripple = str2double(get(handles.Apass, 'String'));
filter.dBstop = str2double(get(handles.Astop, 'String'));
if get(handles.Advanced_options, 'Value')
    filter.FIR_Astop = str2double(get(handles.FIR_Astop, 'String'));
else
    filter.FIR_Astop = 0;
end
filter.Pheq = -1;
filter.channels = get(handles.FIR_1, 'Value') + get(handles.FIR_2, 'Value') * 2;
filter.internal_FIR = get(handles.Use_FIR, 'Value');

if get(handles.Advanced_options, 'Value')
    if get(handles.phase_eq, 'Value')
        filter.Phase_EQ = str2double(get(handles.target_delay, 'String'));
    end
end

name = inputdlg('Save filter as', 'AD9361 Filter Designer');

if get(handles.filter_type, 'Value') == 1
    ad9361.rx.(name{1}) = filter;
else
    filter.DAC_div = get(handles.DAC_by2, 'Value');
    ad9361.tx.(name{1}) = filter;
end
assignin('base', 'AD9361', ad9361);

% --- Executes on button press in connect2target.
function connect2target_Callback(hObject, eventdata, handles)
% hObject    handle to connect2target (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp = get(handles.IP_num,'String');
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
    set(handles.target_get_clock, 'Visible', 'on');
    handles.iio_cmdsrv = obj;
    if ~ isempty(handles.taps)
        set(handles.save2target, 'Visible', 'on');
    end
else
    set(handles.target_get_clock, 'Visible', 'off');
    msgbox('Could not connect to target!', 'Error','error');
end
% Update handles structure
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of connect2target


% --- Executes on button press in design_filter.
function design_filter_Callback(hObject, eventdata, handles)
% hObject    handle to design_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
create_filter(hObject, handles);



function Port_num_Callback(hObject, eventdata, handles)
% hObject    handle to Port_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Port_num as text
%        str2double(get(hObject,'String')) returns contents of Port_num as a double


% --- Executes during object creation, after setting all properties.
function Port_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Port_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function magnitude_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to magnitude_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate magnitude_plot

% --- Executes during object creation, after setting all properties.
function FIR2HB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FIR2HB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DAC_by2.
function DAC_by2_Callback(hObject, eventdata, handles)
% hObject    handle to DAC_by2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fix_converter2pll(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns DAC_by2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DAC_by2


% --- Executes during object creation, after setting all properties.
function DAC_by2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAC_by2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FIR2HB.
function FIR2HB_Callback(hObject, eventdata, handles)
% hObject    handle to FIR2HB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FIR2HB contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FIR2HB
fix_FIR2HB(hObject, handles);
fix_HB2converter(hObject, handles);
converter_rate = get_data_rate(handles) * HB_interp(handles) * fir_interp(handles);
set_converter_rate(handles, converter_rate);

fix_converter2pll(hObject, handles);


% --- Executes during object creation, after setting all properties.
function results_taps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to results_taps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over Pll_rate.
function Pll_rate_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Pll_rate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
