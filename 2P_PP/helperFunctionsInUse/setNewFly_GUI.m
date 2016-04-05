function varargout = setNewFly_GUI(varargin)
% SETNEWFLY_GUI MATLAB code for setNewFly_GUI.fig
%      SETNEWFLY_GUI, by itself, creates a new SETNEWFLY_GUI or raises the existing
%      singleton*.
%
%      H = SETNEWFLY_GUI returns the handle to a new SETNEWFLY_GUI or the handle to
%      the existing singleton*.
%
%      SETNEWFLY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETNEWFLY_GUI.M with the given input arguments.
%
%      SETNEWFLY_GUI('Property','Value',...) creates a new SETNEWFLY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setNewFly_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setNewFly_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setNewFly_GUI

% Last Modified by GUIDE v2.5 11-Jun-2015 13:33:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setNewFly_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @setNewFly_GUI_OutputFcn, ...
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


% --- Executes just before setNewFly_GUI is made visible.
function setNewFly_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setNewFly_GUI (see VARARGIN)

% Choose default command line output for setNewFly_GUI
handles.output = hObject;


% Inputs
handles.FlyNum = getpref('scimSavePrefs', 'flyNum');
% Outputs
handles.exportFly = handles.FlyNum;
handles.exportExperimenter = get(handles.nameExperimenter, 'String');
handles.exportTxtLog = [];
%set fields:
set(handles.currentFly, 'String', handles.FlyNum);
set(handles.eclosiontx, 'String', datestr(now,'YYmmdd'));
set(handles.righttx, 'String', 'ok, a2 glued, piezo attached');
set(handles.lefttx, 'String', 'ok, a2 glued');
set(handles.linetx, 'String', 'het: UAS-GCaMP6F x ');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setNewFly_GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = setNewFly_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.exportFly;
varargout{2} = handles.exportExperimenter;
varargout{3} = handles.exportTxtLog; 
delete(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    %the GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % the GUI is no longer waiting, just close it
    % Hint: delete(hObject) closes the figure
    delete(hObject);
end





% --- Executes on button press in continueFly.
function continueFly_Callback(hObject, eventdata, handles)
% hObject    handle to continueFly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.exportExperimenter = get(handles.nameExperimenter, 'String');
handles.exportTxtLog = [];
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
textAll = [];
text = get(handles.linetx, 'String');
textAll = [textAll, 'Line:\n', text, '\n\n'];

text = get(handles.lefttx, 'String');
textAll = [textAll, 'Left Antenna:\n', text, '\n\n'];

text = get(handles.righttx, 'String');
textAll = [textAll, 'Right Antenna:\n', text, '\n\n'];

text = get(handles.eclosiontx, 'String');
textAll = [textAll, 'Eclosion Date:\n', text, '\n\n'];

text = get(handles.notestx, 'String');
textAll = [textAll, 'Notes on dissection:\n', text, '\n\n'];

experimenter = get(handles.nameExperimenter, 'String');
textAll = [textAll, 'Experimenter:\n', experimenter, '\n\n'];

%update NumFly pref:
newfly = handles.FlyNum + 1;
setpref('scimSavePrefs', 'flyNum', newfly);
handles.exportFly    = newfly;
handles.exportExperimenter = experimenter;
handles.exportTxtLog = textAll;
guidata(hObject, handles);

figure1_CloseRequestFcn(handles.figure1, eventdata, handles)






function linetx_Callback(hObject, eventdata, handles)
% hObject    handle to linetx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of linetx as text
%        str2double(get(hObject,'String')) returns contents of linetx as a double



% --- Executes during object creation, after setting all properties.
function linetx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linetx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lefttx_Callback(hObject, eventdata, handles)
% hObject    handle to lefttx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lefttx as text
%        str2double(get(hObject,'String')) returns contents of lefttx as a double



% --- Executes during object creation, after setting all properties.
function lefttx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lefttx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function righttx_Callback(hObject, eventdata, handles)
% hObject    handle to righttx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of righttx as text
%        str2double(get(hObject,'String')) returns contents of righttx as a double


% --- Executes during object creation, after setting all properties.
function righttx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to righttx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eclosiontx_Callback(hObject, eventdata, handles)
% hObject    handle to eclosiontx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eclosiontx as text
%        str2double(get(hObject,'String')) returns contents of eclosiontx as a double


% --- Executes during object creation, after setting all properties.
function eclosiontx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eclosiontx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function notestx_Callback(hObject, eventdata, handles)
% hObject    handle to notestx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notestx as text
%        str2double(get(hObject,'String')) returns contents of notestx as a double


% --- Executes during object creation, after setting all properties.
function notestx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notestx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nameExperimenter_Callback(hObject, eventdata, handles)
% hObject    handle to nameExperimenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nameExperimenter as text
%        str2double(get(hObject,'String')) returns contents of nameExperimenter as a double


% --- Executes during object creation, after setting all properties.
function nameExperimenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nameExperimenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
