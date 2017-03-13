function varargout = input_GUI(varargin)
% INPUT_GUI MATLAB code for input_GUI.fig
%      INPUT_GUI, by itself, creates a new INPUT_GUI or raises the existing
%      singleton*.
%
%      H = INPUT_GUI returns the handle to a new INPUT_GUI or the handle to
%      the existing singleton*.
%
%      INPUT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INPUT_GUI.M with the given input arguments.
%
%      INPUT_GUI('Property','Value',...) creates a new INPUT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before input_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to input_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help input_GUI

% Last Modified by GUIDE v2.5 13-Mar-2017 00:52:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @input_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @input_GUI_OutputFcn, ...
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


% --- Executes just before input_GUI is made visible.
function input_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to input_GUI (see VARARGIN)

% Choose default command line output for input_GUI
handles.output = hObject;

% Create tab group
handles.tgroup = uitabgroup('Parent',handles.panel_tag ,'TabLocation','top');
handles.tab1 = uitab('Parent',handles.tgroup,'Title','Input Simulation');
handles.tab2 = uitab('Parent',handles.tgroup,'Title','Radiation Model');
handles.tab3 = uitab('Parent',handles.tgroup,'Title','Sensor Configuration');
handles.tab4 = uitab('Parent',handles.tgroup,'Title','Algorithm Configuration');

% Place panels into each tab
set(handles.panel1,'Parent',handles.tab1);
set(handles.panel2,'Parent',handles.tab2);

% Reposition of each panel to same location as panel 1
set(handles.panel2,'position',get(handles.panel1,'position'));

% Update handles structure
guidata(hObject, handles);

uiwait;

% UIWAIT makes input_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = input_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = [ntargets nsteps step_distance mean_distance calibration_steps]
varargout{1} = [handles.ntargets handles.nsteps handles.step_distance handles.mean_distance handles.calibration_steps]; 
varargout{2} = [handles.xmin handles.xmax ; handles.ymin handles.ymax];

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function text_targets_Callback(hObject, eventdata, handles)
% hObject    handle to text_targets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Number of targets 
handles.ntargets = str2double(get(handles.text_targets,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_targets as text
%        str2double(get(hObject,'String')) returns contents of text_targets as a double


% --- Executes during object creation, after setting all properties.
function text_targets_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_targets (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_steps_Callback(hObject, eventdata, handles)
% hObject    handle to text_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Maximum number of steps of a user
handles.nsteps = str2double(get(handles.text_steps,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_steps as text
%        str2double(get(hObject,'String')) returns contents of text_steps as a double


% --- Executes during object creation, after setting all properties.
function text_steps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_steps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_calibration_Callback(hObject, eventdata, handles)
% hObject    handle to text_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Number of observations during calibration period (empty scenario)
handles.calibration_steps = str2double(get(handles.text_calibration,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_calibration as text
%        str2double(get(hObject,'String')) returns contents of text_calibration as a double


% --- Executes during object creation, after setting all properties.
function text_calibration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function text_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to text_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - xmin
handles.xmin = str2double(get(handles.text_xmin,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_xmin as text
%        str2double(get(hObject,'String')) returns contents of text_xmin as a double


% --- Executes during object creation, after setting all properties.
function text_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to text_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - xmax
handles.xmax = str2double(get(handles.text_xmax,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_xmax as text
%        str2double(get(hObject,'String')) returns contents of text_xmax as a double


% --- Executes during object creation, after setting all properties.
function text_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to text_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - ymin
handles.ymin = str2double(get(handles.text_ymin,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_ymin as text
%        str2double(get(hObject,'String')) returns contents of text_ymin as a double


% --- Executes during object creation, after setting all properties.
function text_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function text_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to text_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - ymax
handles.ymax = str2double(get(handles.text_ymax,'String'));

% Update handles structure
guidata(hObject, handles);

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end

% Hints: get(hObject,'String') returns contents of text_ymax as text
%        str2double(get(hObject,'String')) returns contents of text_ymax as a double

% --- Executes during object creation, after setting all properties.
function text_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in button_createpaths.
function button_createpaths_Callback(hObject, eventdata, handles)
% hObject    handle to button_createpaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    %% Input
    % Paths that the targets follow inside the considered map
    handles.dimensions = [handles.xmin handles.xmax ; handles.ymin handles.ymax];
    users_path = create_path(handles.ntargets, handles.dimensions, handles.nsteps, handles.step_distance, handles.mean_distance);
    axes(handles.axes1);
    cla
    for i = 1:handles.ntargets
        plot(users_path(1,:,i),users_path(2,:,i))
        hold on
    end
    hold on
    grid on
    title('Paths of the targets in the monitored area')
    xlabel('X')
    ylabel('Y')
    axis([handles.dimensions(1,1) handles.dimensions(1,2) handles.dimensions(2,1) handles.dimensions(2,2)])
    
uiresume;

    
    
function text_stepdistance_Callback(hObject, eventdata, handles)
% hObject    handle to text_stepdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Input - step distance in meters [m]
handles.step_distance = str2double(get(handles.text_stepdistance,'String'));

% Update handles structure
guidata(hObject,handles)

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_stepdistance as text
%        str2double(get(hObject,'String')) returns contents of text_stepdistance as a double


% --- Executes during object creation, after setting all properties.
function text_stepdistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_stepdistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function text_meandistance_Callback(hObject, eventdata, handles)
% hObject    handle to text_meandistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Input - Average straight distance of a target for modeling the paths
handles.mean_distance = str2double(get(handles.text_meandistance,'String'));

% Update handles structure
guidata(hObject,handles)

% Press enter button 
key = get(gcf,'CurrentKey');
if(strcmp (key , 'return'))
    button_createpaths_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of text_meandistance as text
%        str2double(get(hObject,'String')) returns contents of text_meandistance as a double


% --- Executes during object creation, after setting all properties.
function text_meandistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_meandistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
