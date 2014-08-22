function varargout = NNLSFittingOptions(varargin)
% NNLSFITTINGOPTIONS M-file for NNLSFittingOptions.fig
%%%%%
% Created by Thorarin Bjarnason for the ImagingInformatics research group
% at the University of Calgary.
% http://www.imaginginformatics.ca/open-source
%%%%%%
%      NNLSFITTINGOPTIONS, by itself, creates a new NNLSFITTINGOPTIONS or raises the existing
%      singleton*.
%
%      H = NNLSFITTINGOPTIONS returns the handle to a new NNLSFITTINGOPTIONS or the handle to
%      the existing singleton*.
%
%      NNLSFITTINGOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NNLSFITTINGOPTIONS.M with the given input arguments.
%
%      NNLSFITTINGOPTIONS('Property','Value',...) creates a new NNLSFITTINGOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NNLSFittingOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NNLSFittingOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NNLSFittingOptions

% Last Modified by GUIDE v2.5 26-Jun-2008 14:27:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NNLSFittingOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @NNLSFittingOptions_OutputFcn, ...
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


%%
% --- Executes just before NNLSFittingOptions is made visible.
function NNLSFittingOptions_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NNLSFittingOptions (see VARARGIN)

% Choose default command line output for NNLSFittingOptions
handles.output = hObject;

% %get data from original gui that is stored in the omni workspace
handles.FitParam = getappdata( 0, 'handles_FitParam' );
%set variables to gui
set( handles.EditTextStartEcho, 'String', ...
    num2str( handles.FitParam.StartEcho ) );
set( handles.EditTextEchoCutoff, 'String', ...
    num2str( handles.FitParam.EchoCutoff ) );
set( handles.EditTextT2BasisLength, 'String', ...
    num2str( handles.FitParam.T2BasisLength ) );
set( handles.EditTextT2Min, 'String', num2str( handles.FitParam.T2Min ) );
set( handles.EditTextT2Max, 'String', num2str( handles.FitParam.T2Max ) );
set( handles.EditTextEchoSpacing, 'String', ...
    num2str( handles.FitParam.EchoSpacing ) );
set( handles.ListBoxEchoes, 'value', handles.FitParam.WhichEchoes );


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NNLSFittingOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NNLSFittingOptions_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL,INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%
% Editable text boxes.
%%%%%%%%


%%
function EditTextEchoSpacing_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
EchoSpacing = str2double(get(hObject,'String'));
if isempty(EchoSpacing)
    set(hObject,'String',num2str(handles.FitParam.EchoSpacing,'%.3f'));
    return;
else
    handles.FitParam.EchoSpacing = EchoSpacing;
    %plot if needed
    if handles.ROI.exists %if roi exists, decay exists as well
      %Use ROI info in order to recreate decay data
      handles = UseROI(handles);
      %  
    end
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextEchoSpacing_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextEchoSpacing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function EditTextEchoCutoff_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
EchoCutoff = str2double(get(hObject,'String'));
if isempty(EchoCutoff)
    set(hObject,'String',num2str(handles.FitParam.EchoCutoff,'%.3f'));
    return;
else
    handles.FitParam.EchoCutoff = EchoCutoff;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextEchoCutoff_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextEchoCutoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function EditTextStartEcho_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
StartEcho = str2double(get(hObject,'String'));
if isempty(StartEcho)
    set(hObject,'String',num2str(handles.FitParam.StartEcho),'%.3f');
    return;
else
    handles.FitParam.StartEcho = StartEcho;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextStartEcho_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextStartEcho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function EditTextT2BasisLength_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
T2BasisLength = str2double(get(hObject,'String'));
if isempty(T2BasisLength)
    set(hObject,'String',num2str(handles.FitParam.T2BasisLength,'%.3f'));
    return;
else
    handles.FitParam.T2BasisLength = T2BasisLength;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextT2BasisLength_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextT2BasisLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function EditTextT2Max_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
T2max = str2double(get(hObject,'String'));
if isempty(T2max)
    set(hObject,'String',num2str(handles.FitParam.T2Max,'%.3f'));
    return;
else
    handles.FitParam.T2Max = T2max;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextT2Max_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextT2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function EditTextT2Min_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
T2min = str2double(get(hObject,'String'));
if isempty(T2min)
    set(hObject,'String',num2str(handles.FitParam.T2Min,'%.3f'));
    return;
else
    handles.FitParam.T2Min = T2min;
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function EditTextT2Min_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to EditTextT2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









%%
% List box.
%%%%%%%%


%%
% --- Executes on selection change in ListBoxEchoes.
function ListBoxEchoes_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
handles.FitParam.WhichEchoes = get( hObject,'Value'); %1=All Echoes, 2=Even, 3=Odd

%Update handles
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function ListBoxEchoes_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to ListBoxEchoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






%%
% push buttom
%%%%%%%

% --- Executes on button press in PushButtonFitData.
function PushButtonFitData_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
% hObject    handle to PushButtonFitData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%return parameters to omni workspace so the calling gui can access them
setappdata( 0, 'handles_FitParam', handles.FitParam );
%set flag to 1 in omniworkspace to confirm that this button was pressed and
%figure1_DeleteFcn was not called by other exiting methods
setappdata( 0, 'handles_ContinueFit', 1 )

%delete figure
figure1_DeleteFcn;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok<INUSD>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close NNLSFittingOptions



