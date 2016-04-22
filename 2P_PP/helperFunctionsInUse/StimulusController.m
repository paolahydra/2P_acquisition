function varargout = StimulusController(varargin)
% STIMULUSCONTROLLER MATLAB code for StimulusController.fig
%      STIMULUSCONTROLLER, by itself, creates a new STIMULUSCONTROLLER or raises the existing
%      singleton*.
%
%      H = STIMULUSCONTROLLER returns the handle to a new STIMULUSCONTROLLER or the handle to
%      the existing singleton*.
%
%      STIMULUSCONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMULUSCONTROLLER.M with the given input arguments.
%
%      STIMULUSCONTROLLER('Property','Value',...) creates a new STIMULUSCONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StimulusController_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StimulusController_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StimulusController

% Last Modified by GUIDE v2.5 27-Aug-2015 12:33:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StimulusController_OpeningFcn, ...
                   'gui_OutputFcn',  @StimulusController_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    %only the first time it's called this will take the actual input to the function,
    %which is a filepath string, and produce an error, so I am controlling for it.
    if isempty(regexp(varargin{1}, '[\\\/\:]'))
        gui_State.gui_Callback = str2func(varargin{1});
    end
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%DONE
% --- Executes just before StimulusController is made visible.
function StimulusController_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StimulusController (see VARARGIN)


% Inputs
if length(varargin) >= 1
    handles.runfolder = varargin{1};
else
    handles.runfolder = getpref('scimSavePrefs', 'dataDirectory');
end
if length(varargin) >= 2
    handles.endPadDur = varargin{2}.endPadDur;        %passed to the interpreter
    handles.startPadDur = varargin{2}.startPadDur;  %passed to the interpreter
    handles.fs = varargin{2}.fs;    %if not in input, default gets found here
    handles.maxVoltage = varargin{2}.maxVoltage;
    if isfield(varargin{2},'ITI')
        handles.ITI = varargin{2}.ITI;
    end
    if isfield(varargin{2},'random')
        handles.random = varargin{2}.random;
    end
    if isfield(varargin{2},'samplingTime2P')
        handles.samplingTime2P = varargin{2}.samplingTime2P;
        handles.maxiPreWL = varargin{2}.maxiPreWL;
        handles.maxiReps = varargin{2}.maxiReps;
        handles.maxiITI = varargin{2}.maxiITI;
    end
    if isfield(varargin{2},'stimulusPath')
        handles.stimulusPath = varargin{2}.stimulusPath;
    end
else
    a = AuditoryStimulus;
    handles.endPadDur = a.endPadDur;
    handles.startPadDur = a.startPadDur;
    handles.fs = a.sampleRate;
    handles.maxVoltage = a.maxVoltage;
    delete(a)
    handles.ITI = 0;
    handles.stimulusPath = [];
end


path2StimFolder = which('PipStimulus');
[path2StimFolder,~,~] = fileparts(path2StimFolder);
availableStimuli = dir(fullfile(path2StimFolder, '*.m'));
availableStimuli = {availableStimuli.name}; %cell
%better way to remove the extension? regexp? 
for i = 1:length(availableStimuli)
    availableStimuli{i} = availableStimuli{i}(1:end-2);
end
handles.availableStimuli = availableStimuli;
set(handles.availableSt,'String', handles.availableStimuli)

if ~isempty(handles.stimulusPath)
    load(handles.stimulusPath);     %tdata, stimuli
    handles.tdata = tdata;
    handles.stimuli = stimuli;
    handles.nRows = nRows;
    handles.repetitions = repetitions;
    set(handles.table, 'data', handles.tdata);
else
    handles.stimuli = {};
    handles.tdata = {};
    handles.nRows = []; %column vector, one entry per experimental stimulus, updtaed by ADDST, RMST
    handles.repetitions = []; %column vector, one entry per experimental stimulus, updated by ADDST, RMST AND editParameters (value)...
end
set(handles.experimSt, 'String', handles.stimuli)
% Outputs
handles.export = [];
guidata(hObject, handles);

% UIWAIT makes StimulusControllerII wait for user response (see UIRESUME)
uiwait(handles.figure1);
% starts = [1; cumsum(handles.nRows(1:end-1))+1]
% ends = cumsum(handles.nRows);

%DONE
% --- Outputs from this function are returned to the command line.
function varargout = StimulusController_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.export.full = handles.tdata;
handles.export.stimuli = handles.stimuli;
handles.export.repetitions = handles.repetitions;
handles.export.fs = handles.fs;
handles.export.endPadDur = handles.endPadDur;        %passed to the interpreter
handles.export.startPadDur = handles.startPadDur;  %passed to the interpreter
handles.export.maxVoltage = handles.maxVoltage;
handles.export.nRows = handles.nRows;

if isfield(handles,'ITI')
    handles.export.ITI = handles.ITI;
end
if isfield(handles,'random')
    handles.export.random = handles.random;
end
if isfield(handles,'samplingTime2P')
    handles.export.samplingTime2P = handles.samplingTime2P;
    handles.export.maxiPreWL = handles.maxiPreWL;
    handles.export.maxiReps = handles.maxiReps;
    handles.export.maxiITI = handles.maxiITI;
end
if isfield(handles,'stimulusPath')
    handles.export.stimulusPath = handles.stimulusPath;
end
varargout{1} = handles.export;
tdata = handles.tdata;
stimuli = handles.stimuli;
nRows = handles.nRows;
repetitions = handles.repetitions;
save(fullfile(handles.runfolder, 'stimuliSettings.mat'), 'tdata', 'stimuli','repetitions','nRows');
datafolder = getpref('scimSavePrefs', 'dataDirectory');
save(fullfile( datafolder, 'stimuliSettings.mat'), 'tdata', 'stimuli','repetitions','nRows'); %update current file setting in main folder
delete(handles.figure1);

%DONE
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isequal(get(hObject, 'waitstatus'), 'waiting')
    %the GUI is still in UIWAIT, use UIRESUME
    uiresume(hObject);
else
    % the GUI is no longer waiting, just close it
    % Hint: delete(hObject) closes the figure
    delete(hObject);
end



%DONE
% --- Executes when entered data in editable cell(s) in table.
function table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
if eventdata.Indices(2) == 3 %parameters
    handles.tdata(eventdata.Indices(1), eventdata.Indices(2)) = {eventdata.EditData}; %string
else %repetitions
    handles.tdata(eventdata.Indices(1), eventdata.Indices(2)) = {eventdata.NewData}; %double
    %update repetitions
    starts = [1; cumsum(handles.nRows(1:end-1))+1];
    iStimChange = find(eventdata.Indices(1)==starts);
    if ~isempty(iStimChange)
        handles.repetitions(iStimChange) = eventdata.NewData;
    end
end
set(hObject, 'data', handles.tdata);
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in table.
function table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)




%DO
% --- Executes on button press in CalculateDur.
function CalculateDur_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateDur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x = stimulusInterpreterII(handles,0);
if isfield(handles,'ITI')
    totDurationMin = (x.totDurRun + length(x.trials)*handles.ITI)/60;
else
    if isfield(handles,'maxiPreWL')
        totDurationMin = (x.totDurRun + handles.maxiPreWL)/60;
    else
        totDurationMin = (x.totDurRun)/60;
    end
end
str = sprintf('%.1f', totDurationMin);
set(handles.totDuration, 'String', str)


%DONE
% --- Executes on button press in Done_exit.
function Done_exit_Callback(hObject, eventdata, handles)
% hObject    handle to Done_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Done_exit
figure1_CloseRequestFcn(handles.figure1, eventdata, handles)


%DONE
% --- Executes on selection change in availableSt.
function availableSt_Callback(hObject, eventdata, handles)
% hObject    handle to availableSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns availableSt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from availableSt
contents = cellstr(get(hObject,'String')); %returns availableSt contents as cell array
handles.addSt = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function availableSt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to availableSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%DONE
% --- Executes on selection change in experimSt.
function experimSt_Callback(hObject, eventdata, handles)
% hObject    handle to experimSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns experimSt contents as cell array
%        contents{get(hObject,'Value')} returns selected item from experimSt
handles.iRemoveSt = get(hObject,'Value');
contents = cellstr(get(hObject,'String')); %returns availableSt contents as cell array
handles.addSt = contents{get(hObject,'Value')};
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function experimSt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experimSt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%DONE
% --- Executes on button press in AddStimulus.
function AddStimulus_Callback(hObject, eventdata, handles)
% hObject    handle to AddStimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addSt = handles.addSt; %single string
%update experimental stimuli list box
handles.stimuli = cat(2, handles.stimuli, {addSt});
set(handles.experimSt, 'String', handles.stimuli)
%add stimuli to table
%make stim and find properties
stim = eval(addSt);
mc = metaclass(stim);
hasDef = cell2mat({mc.PropertyList.HasDefault});
n = find(hasDef==0,1)-1;
properties = {mc.PropertyList(1:n,1).Name};
defaults   = {mc.PropertyList(1:n,1).DefaultValue};
%make first row. (cell)
firstRow = {addSt, '-', '-', 1};
%make following rows
nextRows = {};
for j = 1:length(properties)
    nextRows = cat(1, nextRows, {'', properties{j}, defaults{j},''});
end
%keep record of each stimulus?
handles.nRows = cat(1, handles.nRows, length(properties)+1);
%currentSt keeps track of names and number of stimuli
% handles.durations = cat(1, handles.durations, stimDur);
handles.repetitions = cat(1, handles.repetitions, 1); %default is 1.
%update table
handles.tdata = cat(1, handles.tdata, firstRow);
handles.tdata = cat(1, handles.tdata, nextRows);
set(handles.table, 'data', handles.tdata); %not sure this works here. If not restore old way to do.
guidata(hObject, handles);

    
%DONE
% --- Executes on button press in RemoveStim.
function RemoveStim_Callback(hObject, eventdata, handles)
% hObject    handle to RemoveStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
iRemSt = handles.iRemoveSt; %single stimulus
%update experimental stimuli list box
indices = true(1, length(handles.stimuli));
indices(iRemSt) = false;
handles.stimuli = handles.stimuli(indices);
set(handles.experimSt, 'String', handles.stimuli)
%remove stimuli from table
%find stim's rows
if iRemSt == 1
    rowsRem = 1:handles.nRows(1);
else
    rowsRem = sum(handles.nRows(1:iRemSt-1))+1 : sum(handles.nRows(1:iRemSt));
end
%keep record of each stimulus?
handles.nRows = handles.nRows(indices);
%remove other entries
% handles.durations   = handles.durations(indices);
handles.repetitions = handles.repetitions(indices);
%update table
handles.tdata(rowsRem,:) = [];
set(handles.table, 'data', handles.tdata); %not sure this works here. If not restore old way to do.
guidata(hObject, handles);


% --- Executes on button press in loadStimuli.
function loadStimuli_Callback(hObject, eventdata, handles)
% hObject    handle to loadStimuli (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% datafolder = getpref('scimSavePrefs', 'dataDirectory');
loadStim = uipickfiles('FilterSpec', handles.runfolder, 'REFilter', 'stimuliSettings', 'Output', 'char');
load(loadStim);     %tdata, stimuli


handles.tdata = tdata;
handles.stimuli = stimuli;
handles.nRows = nRows;
handles.repetitions = repetitions; 

set(handles.experimSt, 'String', handles.stimuli)
set(handles.table, 'data', handles.tdata);
guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of loadStimuli
