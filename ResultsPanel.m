function varargout = ResultsPanel(varargin)
% RESULTSPANEL M-file for ResultsPanel.fig
%      RESULTSPANEL, by itself, creates a new RESULTSPANEL or raises the existing
%      singleton*.
%
%      H = RESULTSPANEL returns the handle to a new RESULTSPANEL or the handle to
%      the existing singleton*.
%
%      RESULTSPANEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESULTSPANEL.M with the given input arguments.
%
%      RESULTSPANEL('Property','Value',...) creates a new RESULTSPANEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ResultsPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ResultsPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ResultsPanel

% Last Modified by GUIDE v2.5 17-Jul-2008 14:49:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ResultsPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @ResultsPanel_OutputFcn, ...
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


% --- Executes just before ResultsPanel is made visible.
function ResultsPanel_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ResultsPanel (see VARARGIN)

% Choose default command line output for ResultsPanel
handles.output = hObject;

%import initial regional values from gui
handles.Min1 = str2double( get( handles.TextRegion1Min, 'String' ) );
handles.Max1 = str2double( get( handles.TextRegion1Max, 'String') );
handles.Min2 = str2double( get( handles.TextRegion2Min, 'String') );
handles.Max2 = str2double( get( handles.TextRegion2Max, 'String') );
handles.Min3 = str2double( get( handles.TextRegion3Min, 'String') );
handles.Max3 = str2double( get( handles.TextRegion3Max, 'String') );
% get root handle
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
% set values
setappdata( hAnalyzennlsGUI, 'min1', handles.Min1 )
setappdata( hAnalyzennlsGUI, 'max1', handles.Max1 )
setappdata( hAnalyzennlsGUI, 'min2', handles.Min2 )
setappdata( hAnalyzennlsGUI, 'max2', handles.Max2 )
setappdata( hAnalyzennlsGUI, 'min3', handles.Min3 )
setappdata( hAnalyzennlsGUI, 'max3', handles.Max3 )
%

%determine initial results
for i = 1:3
    % set region
    setappdata( hAnalyzennlsGUI, 'RegionFlag', i )
    GenerateOutputText
    if i == 1
        output_text = getappdata( hAnalyzennlsGUI, ...
            ['output_text', num2str(i)] );
        set( handles.TextRegion1Area, 'String', [' ' output_text ] )
    elseif i == 2
        output_text = getappdata( hAnalyzennlsGUI, ...
            ['output_text', num2str(i)] );
        set( handles.TextRegion2Area, 'String', [' ' output_text ] )
    elseif i == 3
        output_text = getappdata( hAnalyzennlsGUI, ...
            ['output_text', num2str(i)] );
        set( handles.TextRegion3Area, 'String', [' ' output_text ] )
    end
end
%


%create handle to be stored in omni space. Used so other GUIs can tell if
%this gui is opened
setappdata( 0, 'hResultsPanelGUI', gcf )
%

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ResultsPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


%% --- Outputs from this function are returned to the command line.
function varargout = ResultsPanel_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


%% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% remove handle from omni space so that when this GUI is closed, other guis
% can tell
rmappdata( 0, 'hResultsPanelGUI' )





%%%%%%%%%%%%%%%%%%%%%%%%
% EditText boxes
%%%%%%%%%%%%%%%%%%%%%%%%

%%
function TextRegion1Min_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
% get value
handles.Min1 = str2double( get(hObject, 'String') );
%

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'min1', handles.Min1 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 1 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text1' );
set( handles.TextRegion1Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TextRegion1Min_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion1Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white' );
end


%%
function TextRegion1Max_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
%get value
handles.Max1 = str2double( get(hObject, 'String') );
%

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'max1', handles.Max1 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 1 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text1' );
set( handles.TextRegion1Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TextRegion1Max_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion1Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white' );
end


%%
function TextRegion2Min_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%get value
handles.Min2 = str2double( get(hObject, 'String') );
%

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'min2', handles.Min2 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 2 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text2' );
set( handles.TextRegion2Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TextRegion2Min_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion2Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%
function TextRegion2Max_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
handles.Max2 = str2double( get(hObject, 'String') );

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'max2', handles.Max2 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 2 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text2' );
set( handles.TextRegion2Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TextRegion2Max_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion2Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function TextRegion3Min_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
handles.Min3 = str2double( get(hObject, 'String') );

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'min3', handles.Min3 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 3 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text3' );
    set( handles.TextRegion3Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TextRegion3Min_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion3Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%
function TextRegion3Max_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
%get data
handles.Max3 = str2double( get(hObject, 'String') );
%

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%set new parameter
setappdata( hAnalyzennlsGUI, 'max3', handles.Max3 )
setappdata( hAnalyzennlsGUI, 'RegionFlag', 3 )
%

%determine regional values
GenerateOutputText
%

%get output text and write it to gui
output_text = getappdata( hAnalyzennlsGUI, 'output_text3' );
set( handles.TextRegion3Area, 'String', [' ' output_text ] )
%

% Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function TextRegion3Max_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion3Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end















%%%%%%%%%%%%%%%%%%%%%%%%
% Text boxes
%%%%%%%%%%%%%%%%%%%%%%%%


%% --- Executes during object creation, after setting all properties.
function TextRegion1Area_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion1Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes during object creation, after setting all properties.
function TextRegion2Area_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion2Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% --- Executes during object creation, after setting all properties.
function TextRegion3Area_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to TextRegion3Area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







%%%%%%%%%%%%%%%%%%%%%%%%
% Function Call
%%%%%%%%%%%%%%%%%%%%%%%%


%% Function that determines output text
function GenerateOutputText

%import handle from caller gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%

%determine region
Region = getappdata( hAnalyzennlsGUI, 'RegionFlag' );
%

%get function handle that calculates regional fraction
fhT2RegionAttributes = getappdata( hAnalyzennlsGUI, ...
    'fhT2RegionAttributes' );
% Call function
feval( fhT2RegionAttributes )
%

%get values function created
area = getappdata( hAnalyzennlsGUI, ...
    ['Region', num2str(Region), 'Fraction'] );
gmT2 = getappdata( hAnalyzennlsGUI, ['Region', num2str(Region), 'gmT2' ] );
w = getappdata( hAnalyzennlsGUI, ['Region', num2str(Region), 'W'] );
%

% create output_text
if area == -1 %min was > max
    output_text{1} = '';
    output_text{2} = 'min > max, please modify ranges';
    output_text{3} = '';
else
    output_text{1} = ['Area Fraction = ', num2str(area,'%5g')]; 
    output_text{2} = '';
    output_text{3} = ['gmT2 = ',num2str(gmT2,'%5g')];
    output_text{4} = '';
    output_text{5} = 'gmT2 Width Ratio = ';
    output_text{6} = ['  ', num2str(w,'%5g')];
end
%

%write output txt to root
setappdata( hAnalyzennlsGUI, ['output_text', num2str(Region)], ...
    output_text )
%


%end function GernateOutputText





