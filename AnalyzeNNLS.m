function varargout = AnalyzeNNLS(varargin)
% ANALYZENNLS M-file for AnalyzeNNLS.fig
%%%%%
% Created by Thorarin Bjarnason for the ImagingInformatics research group
% at the University of Calgary.
% Thorarin Bjarnason is presently with Interior Health (2011)
% and the University of British Columbia (2010)
% http://sourceforge.net/projects/analyzennls/
%%%%%%
%
%%%%%%
% Major Versions
%
% < 1.2.0 All data was fit with NNLS with the exclusion of the first and
% last points. When opening aNNLS files that were created with these
% versions of AnalyzeNNLS, the handles.VersionFlag = 1
%
% >= 1.2.0 Users are now given the option to analyze the data using all
% echoes, even, or odd. When opening aNNLS files created with version >
% 1.2.0, the handles.VersionFlag = 2
% 
% >= 1.3.0 SNR cuttoff was changed to EchoCutoff
%
% >= 2.1.0 Using GCV for regularization. See function in CVNNLS.m
%
% >= 2.2.0 Calculating gmT2 width ratio
%
% >= 2.3.0 Complex data or Magnitude data specified in UserVar.txt
%
%%%%%
%      ANALYZENNLS, by itself, creates a new ANALYZENNLS or raises the existing
%      singleton*.
%
%      H = ANALYZENNLS returns the handle to a new ANALYZENNLS or the handle to
%      the existing singleton*.
%
%      ANALYZENNLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYZENNLS.M with the given input
%      arguments.
%
%      ANALYZENNLS('Property','Value',...) creates a new ANALYZENNLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalyzeNNLS_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalyzeNNLS_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalyzeNNLS

% Last Modified by GUIDE v2.5 11-Jun-2008 10:01:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalyzeNNLS_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalyzeNNLS_OutputFcn, ...
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


%% --- Executes just before AnalyzeNNLS is made visible.
function AnalyzeNNLS_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% --- Initialize variables in handles structure
fid = fopen('UserVar.txt'); %open file that allows users to edit 
%                                variables they often change
tmp = textscan( fid, '%q' );
tmp = tmp{:};
% values users are allowed to define in a sepearte text file are 
% stored in 'tmp'
handles.DefaultDir = tmp{2};
handles.EchoNumber = 1;
handles.figures.figure_decay = figure('Visible', 'off');
    %decay and fit figure handle
handles.figures.figure_resid = figure('Visible', 'off'); 
    %residual popup figure handle
handles.figures.figure_T2dist = figure('Visible', 'off');
    %T2 distribution popup figure handle
handles.FitParam.T2Min = str2double( tmp{ 8 } );
handles.FitParam.T2Max = str2double( tmp{ 10 } );
handles.FitParam.EchoSpacing = str2double( tmp{ 12 } );
handles.FitParam.StartEcho = str2double( tmp{ 14 } );
handles.FitParam.EchoCutoff = str2double( tmp{ 16 } );
handles.FitParam.WhichEchoes = str2double( tmp{ 18 } );
handles.FitParam.T2BasisLength = str2double( tmp{ 20 } );
%_pp: add factors in UserVar.txt to modify intensity of 1st and 2nd echo
handles.FitParam.FirstEchoFactor = str2double( tmp{ 23 } );
handles.FitParam.SecondEchoFactor = str2double( tmp{ 25 } );
handles.MultiEcho.data = [];
handles.MultiEcho.DataType = [];
handles.ComplexFlag = str2double( tmp{92} ); %0 for mag, 1 for real-valued complex
handles.MultiEcho.FileType = []; %0 for Dunn's matlab type, 1 for Stanisz's 
                                 %P-files, 2 for ParRec, 3 for MEID, 
                                 %4 for UBC bff.gz
handles.MultiEcho.meanData = [];
handles.MultiEcho.te = [];
handles.NNLS.TotalArea = [];
handles.ROI.exists = 0; %used in order to clear previous ROIs
handles.scrsz = get(0,'ScreenSize'); %determines user's screen size
handles.SliceNumber = 1;
handles.ZoomOn = 0;
fclose(fid);
%Turn off buttons that cannot be used at this stage
set( handles.PushButtonWindowLevel, 'Enable', 'off' )
set( handles.ToggleButtonZoom, 'Enable', 'off' )
set( handles.PushbuttonDrawROI, 'Enable', 'off' )
set( handles.PushbuttonLoadROI, 'Enable', 'off' )
set( handles.PushbuttonSaveROI, 'Enable', 'off' )
set( handles.PushbuttonRunNNLS, 'Enable', 'off' )
set( handles.PushbuttonSaveData, 'Enable', 'off' )
% -- End Data initialization

% Choose default command line output for AnalyzeNNLS
handles.output = hObject;

%create handle to be stored in root space that other guis can call
setappdata( 0, 'hAnalyzennlsGUI', gcf )

% Update handles structure
guidata(hObject, handles);

%Two versions of code to try for setting an icon
%Version 1
% warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% jframe=get('AnalyzeNNLS.fig','javaframe');
% jIcon=javax.swing.ImageIcon('C:\AnalyzeNNLSdata\AnalyzeNNLS_Icon.gif');
% jframe.setFigureIcon(jIcon); 
%Version 2
% jFig = get( gcf, 'JavaFrame');
% figIcon = javax.swing.ImageIcon('C:\AnalyzeNNLSdata\AnalyzeNNLS_Icon.gif');
% jFig.setFigureIcon(figIcon)


% UIWAIT makes AnalyzeNNLS wait for user response (see UIRESUME)
% uiwait(handles.figure1);





%% --- Outputs from this function are returned to the command line.
function varargout = AnalyzeNNLS_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes when user attempts to close figure1, the main GUI.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles) %#ok<INUSD,INUSL,DEFNU>

%clean up root handle
rmappdata( 0, 'hAnalyzennlsGUI' );
%

%close all windows
close all
%






%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pushutton callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- Executes on button press in PushbuttonDrawROI.
function PushbuttonDrawROI_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

%Check if we are ready for this stage
if isempty(handles.MultiEcho.data)
    return;
end
%

%Check for previous ROI and get rid of it
%   There might be a more elegant way
if handles.ROI.exists
   %handles = PlotImage(handles);
   handles.ROI.exists = 0;
   delete(handles.ROI.line);
   %clear decay data
   if ishandle( handles.figures.figure_decay )
       close( handles.figures.figure_decay )
   end
   if ishandle( handles.figures.figure_resid )
       close( handles.figures.figure_resid )
   end
   if ishandle( handles.figures.figure_T2dist)
       close( handles.figures.figure_T2dist )
   end
end
%

%Remove ResultsPanel window if it is opened
if getappdata( 0, 'hResultsPanelGUI' ) ~= 0
    close ResultsPanel
end
%

%Draw ROI
axes(handles.MRaxes);
[handles.ROI.mask, handles.ROI.xi, handles.ROI.yi] = roipoly;
%note, for Matlab r2007b, roipoly failed and a workaround is required
%according to Matlab bug report 398256
% see http://www.mathworks.com/support/bugreports/details.html?rp=398256
handles.ROI.line = ...
    line(handles.ROI.xi,handles.ROI.yi,'Color','red','LineWidth',1);
handles.ROI.indicies = find(handles.ROI.mask);
drawnow;
handles.ROI.exists = 1;
%

%Use ROI info
handles = UseROI(handles);
%

%turn buttons as needed
set( handles.PushButtonWindowLevel, 'Enable', 'on' )
%set( handles.ToggleButtonZoom, 'Enable', 'off' )
set( handles.PushbuttonDrawROI, 'Enable', 'on' )
set( handles.PushbuttonLoadROI, 'Enable', 'on' )
set( handles.PushbuttonSaveROI, 'Enable', 'on' )
set( handles.PushbuttonRunNNLS, 'Enable', 'on' )
set( handles.PushbuttonSaveData, 'Enable', 'off' )

%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonDrawROI_Callback

%% --- Executes on button press in PushbuttonLoadData.
function PushbuttonLoadData_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%Remove ResultsPanel window if it is opened
if getappdata( 0, 'hResultsPanelGUI' ) ~= 0
    close ResultsPanel
end
%

%Open file dialog
[name,path,filt]=...
    uigetfile('*.aNNLS','Choose Analyze NNLS file', handles.DefaultDir );
if filt == 0 % user did not select a file
    return;
else
    %load file
    data = caseread([path,name]);
    %Change defaultDir to the dir the user just looked in
    handles.DefaultDir = [path, '*', path(end)];
end
%

%Set region counting variable
RegionCount = 1;
%
%Set complex/magnitude flag for pre 2.3 *.aNNLS files
handles.ComplexFlag = 0;
%

% Parse Information
output_text = cell(1,3); %preallocating for speed
% There must be a string search method to speed this up
for i=1:length( data(:,1) )
    if length( data(i,:) ) > 7
        %Version Number
        if strcmp( data( i,46:52 ), 'Version' )
            if isempty( str2double( data( i,56 ) ) ) || ...
                    str2double( data( i,56 ) ) < 2 
                handles.FitParam.WhichEchoes = 1;
                handles.VersionFlag = 1; %aNNLS version < 1.2.0
            else
                handles.VersionFlag = 2; %aNNLS Version >=1.2.0
            end
        end
        %Slice
        if strcmp( data( i,1:15 ),'Slice Number = ')
            handles.SliceNumber = str2double( data( i, 16 ) ); 
        end
        %Echo Spacing
        if strcmp( data( i,1:15 ),'Echo Spacing = ')
            handles.FitParam.EchoSpacing = str2double( data( i,16:end ) );
        end
        %Chi Used
        if strcmp( data( i,1:13 ),'Chisq Used = ')
        end
        %T2 info
        if strcmp( data( i,1:15 ),'T2 basis consis')
            handles.FitParam.T2BasisLength = str2double( data( ...
                i,21:( strfind(data(i,:),'values') - 1 ) ) );
            handles.FitParam.T2Min = str2double( ...
                data( i, ( strfind( data(i,:),'between' ) + 7 ):...
                ( strfind( data(i,:),'and' ) - 1 ) ) );
            handles.FitParam.T2Max = str2double( ...
                data( i, ( strfind( data(i,:),'and') + 4):end ) );
        end
        %Echo cutoff
        if strcmp( data( i,1:13 ),'Echo cutoff =')
            handles.FitParam.EchoCutoff = str2double( data( i,14:end ) );
        end
        %Complex or Magnitude analysis?
        if strcmp( data( i,1:7 ),'Complex')
            handles.ComplexFlag = 1;
        elseif strcmp( data( i,1:9 ),'Magnitude')
            handles.ComplexFlag = 0;
        end
        %Echoes
        if strcmp( data( i,1:7 ),'Echoes ')
            handles.FitParam.StartEcho = str2double( data(...
                i,8:( strfind( data(i,:),'to' ) - 1 ) ) );
            if handles.VersionFlag == 1
                LastEcho = str2double( data(...
                    i,( strfind( data(i,:),'to' ) +2 ):end ) );
            elseif handles.VersionFlag == 2
                LastEcho = str2double( data(...
                    i,( strfind( data(i,:),'to' ) + 2 ):...
                    ( strfind( data(i,:),',' )-1 ) ) );
            end
            %determine even, odd, or all echoes used
            tmp = data( i,( strfind( data(i,:),',' )+1 ):end );
            if handles.VersionFlag > 1 
                %if tmp is not empty, we are using version 1.2.0 or higher.
                %So even, odd, all cases exist.
                if strcmp( tmp(1:4), ' odd' )
                    handles.FitParam.WhichEchoes = 3;
                elseif strcmp( tmp(1:5), ' even' )
                    handles.FitParam.WhichEchoes = 2;
                elseif strcmp( tmp(1:4), ' all' )
                    handles.FitParam.WhichEchoes = 1;
                end
            end
        end
        %Regions
        if strcmp( data( i,1:7 ), 'Region ')
%            Rmin = str2double( ...
%                data( i,7:( strfind( data(i,:),'to' ) - 1 ) ) );
%            Rmax = str2double( ...
%                data( i,( strfind( data(i,:),'to' ) + 2 ):end ) );
            frac = str2double( data( i+1,13:end ) );
            gmT2 = str2double( data( i+2,9:end ) );
            output_text{1} = ['Area Fraction = ', ...
            num2str(frac,'%5g')];
            output_text{2} = '';
            output_text{3} = ['gmT2 = ', num2str(gmT2,'%5g')];
%             if RegionCount == 1
%                 set( handles.EditTextRegion1Min, 'String', ...
%                     num2str( Rmin ) );
%                 set( handles.EditTextRegion1Max, 'String', ...
%                     num2str( Rmax ) );
%                 set(handles.textRegion1Area,'String',output_text);
%             elseif RegionCount == 2
%                 set( handles.EditTextRegion2Min, 'String', ...
%                     num2str( Rmin ) );
%                 set( handles.EditTextRegion2Max, 'String', ...
%                     num2str( Rmax ) );
%                 set(handles.textRegion2Area,'String',output_text);
%             elseif RegionCount == 3
%                 set( handles.EditTextRegion3Min, 'String', ...
%                     num2str( Rmin ) );
%                 set( handles.EditTextRegion3Max, 'String', ...
%                     num2str( Rmax ) );
%                 set(handles.textRegion3Area,'String',output_text);
%             end
            RegionCount = RegionCount + 1;
        end
        %DC offset
        if strcmp( data( i,1:12 ),'DC offset = ')
            handles.NNLS.DCoffset = str2double( data( i,13:end ) );
        end
        %
        %Original filename
        if strcmp( data( i,1:21 ), 'Original File Path = ')
            tmp = strfind( data(i,:), '     ');
            handles.MultiechoPath = [path, data(i,22:tmp(1)-1) ];
        end
        if strcmp( data( i,1:21 ), 'Original File Name = ')
            tmp = strfind( data(i,:), '        ');
            handles.MultiechoName = data(i,22:tmp(1)-1);
            handles = LoadInformation(hObject,handles);
        end
    end
end
%

%Plot again to update slice number
handles = PlotImage(handles);

%LoadROIfromfile
%change filename to .mat
copyfile([path,name(1:end-15),'.roi'], ...
    [path,name(1:end-15),'.mat']);
load( [ path,name(1:end-15),'.mat' ] );
delete( [ path,name(1:end-15),'.mat' ] );
%Draw ROI
handles.ROI.xi = ROIline.xi;
handles.ROI.yi = ROIline.yi;
handles.ROI.indicies = ROIline.indicies;
axes(handles.MRaxes);
hold on
handles.ROI.line = line(ROIline.xi,ROIline.yi,'Color','red','LineWidth',1);
hold off
%Turn flag on
handles.ROI.exists = 1;
%

%Load Raw Data
A = csvread( [ path,name(1:end-15),'-rawData.csv' ] );
handles.MultiEcho.te = A(:,1);
handles.MultiEcho.meanData = A(:,2);
%Plot Decay
handles = PlotDecay(handles);
%

%Load Fit to Data
A = csvread( [ path,name(1:end-15),'-FitToData.csv' ] );
handles.y_recon = A(:,2);
%

%Determine fit specific information
if handles.FitParam.WhichEchoes == 2 %even case
    handles.Fit.StartEcho = ceil( ( handles.FitParam.StartEcho+1 )/2 );
    handles.FitParam.EchoCutoff = ceil( LastEcho/2 );
    handles.Fit.te = handles.MultiEcho.te( 1:2:end );
    handles.Fit.te = ...
        handles.Fit.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
    handles.Fit.meanData = handles.MultiEcho.meanData( 1:2:end );
    handles.Fit.meanData = ...
        handles.Fit.meanData( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
elseif handles.FitParam.WhichEchoes == 3 %odd case
    handles.Fit.StartEcho = floor( ( handles.FitParam.StartEcho+1 )/2 );
    handles.FitParam.EchoCutoff = floor( LastEcho/2 );
    handles.Fit.te = handles.MultiEcho.te( 2:2:end );
    handles.Fit.te = ...
        handles.Fit.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff);
    handles.Fit.meanData = handles.MultiEcho.meanData( 2:2:end );
    handles.Fit.meanData = ...
        handles.Fit.meanData( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
else %all data
    handles.Fit.StartEcho = handles.FitParam.StartEcho;
%    handles.FitParam.EchoCutoff = LastEcho; %Can likely delete if no issues are found - 2009.02.10
    handles.Fit.te = ...
        handles.MultiEcho.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff);
    handles.Fit.meanData = ...
        handles.MultiEcho.meanData( ...
        handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
end

%Plot Fit
handles = PlotFit(handles);
%Determine resid
resid = handles.Fit.meanData - handles.y_recon;
handles = PlotResiduals(handles,resid);
%

%Load T2 Dist
A = csvread( [ path,name(1:end-15),'-T2dist.csv' ] );
handles.NNLS.T2Basis = A(:,1);
handles.NNLS.amplitudes = A(:,2);
handles.NNLS.T2int = A(:,3);
handles = PlotT2Dist(handles);
% set function handles so T2RegionAttributes can be called
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
setappdata( hAnalyzennlsGUI, 'fhT2RegionAttributes', @T2RegionAttributes)
%set T2 amplitudes to function handles
setappdata( hAnalyzennlsGUI, 'T2amps', handles.NNLS.amplitudes )
%set T2 basis to function handles
setappdata( hAnalyzennlsGUI, 'T2Basis', handles.NNLS.T2Basis )
%set T2 distribution total areato function handles
handles.NNLS.TotalArea = sum( handles.NNLS.amplitudes );
setappdata( hAnalyzennlsGUI, 'T2TotalArea', handles.NNLS.TotalArea )
ResultsPanel
%

%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonLoadData


%% --- Executes on button press in PushbuttonLoadFile.
function PushbuttonLoadFile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%Set slice number and echo number back to 1
handles.SliceNumber = 1;
handles.EchoNumber = 1;
%

%Remove ResultsPanel window if it is opened
if getappdata( 0, 'hResultsPanelGUI' ) ~= 0
    close ResultsPanel
end
%

%Open file dialog
[handles.MultiechoName,handles.MultiechoPath,filt]=...
    uigetfile( {'*.bff.gz;*.dcm;*.REC;*.mat;*.MEID;*fdf;P*.*',...
    'MultiEcho Files (*.bff.gz,*.mat,*.MEID,P*.*)';...
    '*.bff.gz', 'UBC bff file (*.bff.gz)'; ...
    '*.dcm', 'dicom files (*.dcm)'; ...
    '*.REC', 'Philips ParRec files (*.REC)'; ...
    '*.mat',  'Dunn (*.mat)'; ...
    '*.MEID', 'Multiecho Image File (*.MEID)'; ...
    '*.fdf', 'Varian format (*.fdf)'; ...
    'P*.*','Stanisz (P*.*)'}, ...
    'Pick a file', handles.DefaultDir); %#ok<NASGU>

if strcmpi( handles.MultiechoName(end-2:end), 'mat')
    FileType = 0; %Dunn matlab format
elseif strcmpi( handles.MultiechoName(end-2:end), 'REC')
    FileType = 2; %Phillips ParRec format
elseif strcmpi( handles.MultiechoName(end-3:end), 'MEID' )
    FileType = 3; %ImagingInformatics file format
elseif strcmpi( handles.MultiechoName(end-5:end), 'bff.gz' )
    FileType = 4; %UBC bff format
elseif strcmpi( handles.MultiechoName(end-2:end), 'fdf' )
    FileType = 5; %Varian file format
elseif strcmpi( handles.MultiechoName(1), 'P' )
    FileType = 1; %Stanisz P-file format
elseif strcmpi( handles.MultiechoName(end-2:end), 'dcm')
    FileType = 6; %Dicom file format
else
    errordlg('Unknown File Type')
    Files = 0; %#ok<NASGU> %only used for uigetfile
    return;
end
%

%continue if file is valid
handles = LoadInformation(hObject,handles);
%Change defaultDir to the dir the user just looked in
handles.DefaultDir = [handles.MultiechoPath, '*', ...
    handles.MultiechoPath(end)];
%

%Set filetype
handles.MultiEcho.FileType = FileType;
%

%turn buttons as needed
set( handles.PushButtonWindowLevel, 'Enable', 'on' )
set( handles.ToggleButtonZoom, 'Enable', 'on' )
set( handles.PushbuttonDrawROI, 'Enable', 'on' )
set( handles.PushbuttonLoadROI, 'Enable', 'on' )
set( handles.PushbuttonSaveROI, 'Enable', 'off' )
set( handles.PushbuttonRunNNLS, 'Enable', 'off' )
set( handles.PushbuttonSaveData, 'Enable', 'off' )
%


%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonLoadFile_Callback


%% --- Executes on button press in PushbuttonLoadROI.
function PushbuttonLoadROI_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

%Check if we are ready for this stage
if isempty(handles.MultiEcho.data)
    return;
end
%

%Remove ResultsPanel window if it is opened
if getappdata( 0, 'hResultsPanelGUI' ) ~= 0
    close ResultsPanel
end
%

%Check for previous ROI and get rid of it
%   There might be a more elegant way
if handles.ROI.exists == 1
    handles.ROI.exists = 0;
    delete(handles.ROI.line);
%    handles = PlotImage(handles); 
    %clear decay data
    if ishandle( handles.figures.figure_decay )        
        close( handles.figures.figure_decay )    
    end
    if ishandle( handles.figures.figure_resid )
       close( handles.figures.figure_resid )
    end
    if ishandle( handles.figures.figure_T2dist)
        close( handles.figures.figure_T2dist )
    end
end
%

%load ROI
[ROIname,ROIpath,filt]=...
    uigetfile('*.roi','Choose ROI file', handles.DefaultDir );
if filt == 0 % user did not select a file
    guidata(hObject,handles);
    return;
else
    %change filename back to mat
    copyfile([ROIpath,ROIname], ...
        [ROIpath,ROIname(1:end-4),'.mat']);
    %load file, this could be neater
    load([ROIpath,ROIname(1:end-4),'.mat']);
    delete([ROIpath,ROIname(1:end-4),'.mat']);
    %Change defaultDir to the dir the user just looked in
    handles.DefaultDir = [ROIpath, '*', ROIpath(end)];
end
%
handles.ROI.xi = ROIline.xi;
handles.ROI.yi = ROIline.yi;
handles.ROI.indicies = ROIline.indicies;
axes(handles.MRaxes);
hold on
handles.ROI.line = line(ROIline.xi,ROIline.yi,'Color','red','LineWidth',1);
hold off

handles = UseROI(handles);

%Turn flag on
handles.ROI.exists = 1;
%

%turn buttons as needed
set( handles.PushButtonWindowLevel, 'Enable', 'on' )
%set( handles.ToggleButtonZoom, 'Enable', 'off' )
set( handles.PushbuttonDrawROI, 'Enable', 'on' )
set( handles.PushbuttonLoadROI, 'Enable', 'on' )
set( handles.PushbuttonSaveROI, 'Enable', 'on' )
set( handles.PushbuttonRunNNLS, 'Enable', 'on' )
set( handles.PushbuttonSaveData, 'Enable', 'off' )

%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonLoadROI


%% --- Executes on button press in PushbuttonRunNNLS.
function PushbuttonRunNNLS_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

%Check if we are ready for this stage
if isempty(handles.MultiEcho.meanData)
    return;
end
%

%set fit parameters, stored in a common handle, to the omni workspace
setappdata( 0, 'handles_FitParam', handles.FitParam );
%set flag to 0 in omni workspace so that we don't run the fitting routine 
%in NNLSFittingOptions unless a button is pressed. This way, if the user
%cancels, the remaing program will not execute.
setappdata( 0, 'handles_ContinueFit', 0 )
%launch fitting options gui
NNLSFittingOptions
%wait until the new window is closed
uiwait(gcf);
%

%Only execute remaining code if the fitting button is pressed in
%NNLSFittingOptions. This way, when users click the 'x', the fitting
%routine will not execute
if getappdata( 0, 'handles_ContinueFit' ) == 0
    return;
end
%

%get variables back from the fitting options gui
handles.FitParam = getappdata( 0, 'handles_FitParam' );
%clean up after myself
rmappdata( 0, 'handles_FitParam' );
%

%Remove ResultsPanel window if it is opened
if getappdata( 0, 'hResultsPanelGUI' ) ~= 0
    close ResultsPanel
end
%


tic;

%Determine Echo cutoff
if handles.FitParam.EchoCutoff ~= 0
    teLast = handles.FitParam.EchoCutoff;
else
    teLast = handles.MultiEcho.size(3);
end
%

%I should be able to put the basis here and index it below, for now I'm
%going to put the A values in the if statelents. As is, the even/odd only
%works if the proper initial echo is set (like to 1, or 3, etc)

%Generate T2 Basis
handles.NNLS.T2Basis = logspace( log10(handles.FitParam.T2Min), ...
    log10(handles.FitParam.T2Max), handles.FitParam.T2BasisLength);
handles.NNLS.A = ...
    exp( -kron(handles.MultiEcho.te',...
    1./handles.NNLS.T2Basis) );
% %Append DC offset
% handles.NNLS.A = [ handles.NNLS.A ...
%     ones( length( handles.NNLS.A(:,1) ), 1 ) ];


%Run NNLS, keeping in mind which echoes are to be used
if handles.FitParam.WhichEchoes == 2 %even case
    handles.Fit.StartEcho = ceil( ( handles.FitParam.StartEcho+1 )/2 );
    handles.FitParam.EchoCutoff = ceil( teLast/2 );
    handles.Fit.te = handles.MultiEcho.te( 1:2:end );
    handles.Fit.te = ...
        handles.Fit.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
    handles.NNLS.A = handles.NNLS.A( 1:2:end,: );
    handles.NNLS.A = ...
        handles.NNLS.A( handles.Fit.StartEcho:handles.FitParam.EchoCutoff,: );
    handles.Fit.meanData = handles.MultiEcho.meanData( 1:2:end );
    handles.Fit.meanData = ...
        handles.Fit.meanData( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
    % _pp adjust intensity of 1st and 2nd echo - mind change odd /even - 
    % FirstEchoFactor is the first echo in this dataset.
    handles.Fit.meanData(1)= ...
        handles.Fit.meanData(1)*handles.FitParam.FirstEchoFactor;
    % handles.Fit.meanData(2)= ...
    %    handles.Fit.meanData(2)*handles.FitParam.SecondEchoFactor;
elseif handles.FitParam.WhichEchoes == 3 %odd case
    handles.Fit.StartEcho = floor( ( handles.FitParam.StartEcho+1 )/2 );
    handles.FitParam.EchoCutoff = floor( teLast/2 );
    handles.Fit.te = handles.MultiEcho.te( 2:2:end );
    handles.Fit.te = ...
        handles.Fit.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff);
    handles.NNLS.A = handles.NNLS.A( 2:2:end,: );
    handles.NNLS.A = ...
        handles.NNLS.A( handles.Fit.StartEcho:handles.FitParam.EchoCutoff,: );
    handles.Fit.meanData = handles.MultiEcho.meanData( 2:2:end );
    handles.Fit.meanData = ...
        handles.Fit.meanData( handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
    % _pp adjust intensity of 1st and 2nd echo - mind change odd /even -
    % SecondEchoFactor is the first echo in this dataset
    %handles.Fit.meanData(1)= ...
    %    handles.Fit.meanData(1)*handles.FitParam.FirstEchoFactor;
    handles.Fit.meanData(1)= ...
        handles.Fit.meanData(1)*handles.FitParam.SecondEchoFactor;    
else %all data
    handles.Fit.StartEcho = handles.FitParam.StartEcho;
    handles.FitParam.EchoCutoff = teLast;
    handles.Fit.te = ...
        handles.MultiEcho.te( handles.Fit.StartEcho:handles.FitParam.EchoCutoff);
    handles.NNLS.A = ...
        handles.NNLS.A( handles.Fit.StartEcho:handles.FitParam.EchoCutoff,: );
    handles.Fit.meanData = ...
        handles.MultiEcho.meanData( ...
        handles.Fit.StartEcho:handles.FitParam.EchoCutoff );
    % _pp adjust intensity of 1st and 2nd echo.
    handles.Fit.meanData(1)= ...
        handles.Fit.meanData(1)*handles.FitParam.FirstEchoFactor;
    handles.Fit.meanData(2)= ...
        handles.Fit.meanData(2)*handles.FitParam.SecondEchoFactor;
end
%

%Run NNLS
[ handles.NNLS.amplitudes, resnorm, resid] = ...
        CVNNLS(handles.NNLS.A, ...
        handles.Fit.meanData');
toc;
handles.NNLS.chiSqUsed = resnorm;
%

% %Remove DC offset
% handles.NNLS.DCoffset = handles.NNLS.amplitudes(end);
% handles.NNLS.amplitudes = handles.NNLS.amplitudes(1:end-1);
% handles.NNLS.A = handles.NNLS.A(:,1:end-1);
%
handles.NNLS.DCoffset = 0; %No DC offset fit to data

%Determine progressive integral of T2 distribution
handles.NNLS.T2int = cumsum(handles.NNLS.amplitudes) .* ...
    max(handles.NNLS.amplitudes) ./ sum(handles.NNLS.amplitudes);
%

%Calculate Fit
handles.y_recon = handles.NNLS.A * ...
    [handles.NNLS.amplitudes] + handles.NNLS.DCoffset;
%

%Plot fit
handles = PlotDecay(handles);
handles = PlotFit(handles);
%

%Plot residuals
handles = PlotResiduals(handles, resid);
%

%Plot T2 Dist
handles = PlotT2Dist(handles);
%

%store amplitudes for later
handles.NNLS.TotalArea = sum(handles.NNLS.amplitudes); 
%

hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
setappdata( hAnalyzennlsGUI, 'fhT2RegionAttributes', @T2RegionAttributes)
        %amplitudes
setappdata( hAnalyzennlsGUI, 'T2amps', handles.NNLS.amplitudes )
        %T2 basis
setappdata( hAnalyzennlsGUI, 'T2Basis', handles.NNLS.T2Basis )
        %total area
setappdata( hAnalyzennlsGUI, 'T2TotalArea', handles.NNLS.TotalArea )
ResultsPanel

%turn buttons as needed
set( handles.PushButtonWindowLevel, 'Enable', 'on' )
%set( handles.ToggleButtonZoom, 'Enable', 'off' )
set( handles.PushbuttonDrawROI, 'Enable', 'on' )
set( handles.PushbuttonLoadROI, 'Enable', 'on' )
set( handles.PushbuttonSaveROI, 'Enable', 'on' )
set( handles.PushbuttonRunNNLS, 'Enable', 'on' )
set( handles.PushbuttonSaveData, 'Enable', 'on' )

%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonRunNNLS


%% --- Executes on button press in PushbuttonSaveData.
function PushbuttonSaveData_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

%Choose Root Filename
currentpath = pwd;
tmp = datevec(date);
if ( handles.MultiEcho.FileType == 0 )...
       || ( handles.MultiEcho.FileType == 2 ) %Dunn, Phillips
    newpath = [handles.MultiechoPath handles.MultiechoName(1:end-4)...
        handles.MultiechoPath(end)];
    Filename = [handles.MultiechoName(1:end-4), '-', num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3))];
elseif handles.MultiEcho.FileType == 3 %MEID data
    newpath = [handles.MultiechoPath handles.MultiechoName(1:end-5)...
        handles.MultiechoPath(end)];
    Filename = [handles.MultiechoName(1:end-5), '-', num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3))];
elseif handles.MultiEcho.FileType == 4 %UBC data
    newpath = [ handles.MultiechoPath handles.MultiechoName(1:end-7)...
        handles.MultiechoPath(end)];
    Filename = [handles.MultiechoName(1:end-7), '-', num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3))];
elseif handles.MultiEcho.FileType == 1 %Stanisz Data
    tmppath = regexprep( handles.MultiechoName, '\.', '_');
    newpath = [handles.MultiechoPath tmppath...
        handles.MultiechoPath(end)];
    Filename = [tmppath, '-', num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3))];
elseif handles.MultiEcho.FileType == 6 %dicom case
        %Assuming all folder contents make up a single multiecho file
    newpath = [handles.MultiechoPath 'AnalyzeNNLSData'...
        handles.MultiechoPath(end) ];
%    newpath = [handles.MultiechoPath 'AnalyzeNNLS' num2str(tmp(1)) ...
%        num2str(tmp(2)) num2str(tmp(3)) ];    
    Filename = ['AnalyzeNNLS-' num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3)) ];    
end


%0 for Dunn's matlab type, 1 for Stanisz's 
% P-files, 2 for ParRec, 3 for MEID, 6 for dicom



mkdir(newpath);
newpath = [newpath 'AnalyzeNNLSData' handles.MultiechoPath(end)];
mkdir(newpath);
cd(newpath);
[file,path] = uiputfile(Filename,'Filename root to use');
cd(currentpath);
%

%check if user aborted
if file == 0
    return;
end
%

%Append further filename information
file = [file,'-Slice',num2str(handles.SliceNumber)];
%
%even odd or all echoes?
if handles.FitParam.WhichEchoes == 1
    tmp = 'all';
elseif handles.FitParam.WhichEchoes == 2
    tmp = 'even';
elseif handles.FitParam.WhichEchoes == 3
    tmp = 'odd';
end
%Append futher filename information
file = [file, '-', tmp, '_echoes'];
%

%save ROI
%first define variable ROIline
ROIline.xi = handles.ROI.xi;
ROIline.yi = handles.ROI.yi;
ROIline.indicies = handles.ROI.indicies;
save( [path,file,'.mat'], 'ROIline');
%Change extension to .roi
movefile([path,file,'.mat'], [path,file,'.roi']);
%

%Save fit and raw data
csvwrite([path,file,'-rawData.csv'], [handles.MultiEcho.te;...
    handles.MultiEcho.meanData]' );
csvwrite([path,file,'-FitToData.csv'], ...
    [handles.Fit.te;handles.y_recon']' );
%

%Save distribution
csvwrite([path,file,'-T2dist.csv'], [handles.NNLS.T2Basis; ...
    handles.NNLS.amplitudes'; handles.NNLS.T2int']' );
%;     

%Additional Info
a = datevec(date);
i = 1;
output_text{i} = ['These files were generated using AnalyzeNNLS ', ... 
    'Version 2.3, an analysis program created by Thorarin Bjarnason ', ...
    'in 2006 - 2011. ', ...
    'Please note that the gmT2 width ratio is only well defined for ', ...
    'T2 distribution regions with log-normal-type peaks. ', ...
    'These files were generated on ',...
    num2str(a(1)), '.', num2str(a(2)), '.', num2str(a(3))];
i = i+1;
%title
output_text{i} = '  Scan information';
i = i+1;
%slices
if length( handles.MultiEcho.size ) == 3 
    a=1;
else 
    a = handles.MultiEcho.size(4);
end
output_text{i} = ['Slice Number = ', num2str(handles.SliceNumber),...
    ' of ', num2str(a)];
i = i+1;
%echoes
a = num2str( handles.MultiEcho.size(3) );
output_text{i} = ['Total Echoes = ', num2str(a)];
i = i+1;
output_text{i} = ['Echo Spacing = ', num2str(handles.FitParam.EchoSpacing)];
i = i+1;
output_text{i} = '';
i = i+1;
%Fitting Information
output_text{i} = '  Fitting Information';
i = i+1;
output_text{i} = ['Chisq Used = ', num2str(handles.NNLS.chiSqUsed)];
i = i+1;
output_text{i} = ['T2 basis consists of ', ...
    num2str(handles.FitParam.T2BasisLength), ...
    ' values logarithmically spaced between ', num2str(handles.FitParam.T2Min),...
    ' and ', num2str(handles.FitParam.T2Max) ];
i = i+1;
output_text{i} = ['Echo cutoff = ', num2str(handles.FitParam.EchoCutoff) ];
i = i+1;
if handles.ComplexFlag == 0
    output_text{i} = 'Magnitude Analysis';
elseif handles.ComplexFlag == 1
    output_text{i} = 'Complex Real-Valued Analysis';
end
i = i+1;
output_text{i} = '';
i = i+1;
%Results
output_text{i} = '  Results';
i = i+1;
output_text{i} = ['Number of voxels used = ', ...
    num2str( length( handles.ROI.indicies)) ];
i = i+1;
%even odd or all echoes?
if handles.FitParam.WhichEchoes == 1
    tmp = 'all';
elseif handles.FitParam.WhichEchoes == 2
    tmp = 'even';
elseif handles.FitParam.WhichEchoes == 3
    tmp = 'odd';
end
%
output_text{i} = ['Echoes ', num2str(handles.FitParam.StartEcho),...
    ' to ', num2str(handles.FitParam.EchoCutoff), ' , ', tmp ];
% Regional Fractions and gmT2s
%determine handle to root gui
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%Region 1
minval = getappdata( hAnalyzennlsGUI, 'min1' );
maxval = getappdata( hAnalyzennlsGUI, 'max1' );
area = getappdata( hAnalyzennlsGUI, 'Region1Fraction' );
gmT2 = getappdata( hAnalyzennlsGUI, 'Region1gmT2' );
w = getappdata( hAnalyzennlsGUI, 'Region1W' );
i = i+1;
output_text{i} = ['Region ', num2str(minval), ' to ', num2str(maxval)];
i = i+1;
output_text{i} = ['  Fraction = ', num2str(area)];
i = i+1;
output_text{i} = ['  gmT2 = ', num2str(gmT2)];
i = i+1;
output_text{i} = ['  gmT2 Width Ratio = ', num2str(w)];
%Region 2
minval = getappdata( hAnalyzennlsGUI, 'min2' );
maxval = getappdata( hAnalyzennlsGUI, 'max2' );
area = getappdata( hAnalyzennlsGUI, 'Region2Fraction' );
gmT2 = getappdata( hAnalyzennlsGUI, 'Region2gmT2' );
w = getappdata( hAnalyzennlsGUI, 'Region2W' );
i = i+1;
output_text{i} = ['Region ', num2str(minval), ' to ', num2str(maxval)];
i = i+1;
output_text{i} = ['  Fraction = ', num2str(area)];
i = i+1;
output_text{i} = ['  gmT2 = ', num2str(gmT2)];
i = i+1;
output_text{i} = ['  gmT2 Width Ratio = ', num2str(w)];
%Region 3
minval = getappdata( hAnalyzennlsGUI, 'min3' );
maxval = getappdata( hAnalyzennlsGUI, 'max3' );
area = getappdata( hAnalyzennlsGUI, 'Region3Fraction' );
gmT2 = getappdata( hAnalyzennlsGUI, 'Region3gmT2' );
w = getappdata( hAnalyzennlsGUI, 'Region3W' );
i = i+1;
output_text{i} = ['Region ', num2str(minval), ' to ', num2str(maxval)];
i = i+1;
output_text{i} = ['  Fraction = ', num2str(area)];
i = i+1;
output_text{i} = ['  gmT2 = ', num2str(gmT2)];
i = i+1;
output_text{i} = ['  gmT2 Width Ratio = ', num2str(w)];
%
i = i+1;
output_text{i} = ['DC offset = ', ...
    num2str(handles.NNLS.DCoffset/sum(handles.NNLS.amplitudes)) ];
i = i+1;
output_text{i} = '';
i = i+1;
output_text{i} = ['Original File Path = ..',...
    handles.MultiechoPath(end),'..',handles.MultiechoPath(end)];
i = i+1;
output_text{i} = ['Original File Name = ', handles.MultiechoName];
%Write to file
strmat = str2mat(output_text);
casewrite(strmat, [path,file,'-DataVals.aNNLS'])
%

%Update handles
guidata(hObject,handles);
%
% -- End PushbuttonSaveData



%% --- Executes on button press in PushbuttonSaveROI.
function PushbuttonSaveROI_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

%Check for previous ROI and get rid of it
if ~handles.ROI.exists
    return; 
end
%

%Save ROI as mat file renamed to roi
ROIline.xi = handles.ROI.xi;
ROIline.yi = handles.ROI.yi;
ROIline.indicies = handles.ROI.indicies;
currentpath = pwd;
tmp = datevec(date);
if ( handles.MultiEcho.FileType == 0 )...
       || ( handles.MultiEcho.FileType == 2 ) %Dunn, Phillips
    newpath = [handles.MultiechoPath handles.MultiechoName(1:end-4)...
    handles.MultiechoPath(end)];
elseif handles.MultiEcho.FileType == 3 %MEID data
    newpath = [handles.MultiechoPath handles.MultiechoName(1:end-5)...
        handles.MultiechoPath(end)];
    Filename = [handles.MultiechoName(1:end-5), '-', date]; %#ok<NASGU>
elseif handles.MultiEcho.FileType == 4 %UBC bff
    newpath = [handles.MultiechoPath handles.MultiechoName(1:end-7)...
        handles.MultiechoPath(end)];
elseif handles.MultiEcho.FileType == 1 %Stanisz Data
    tmppath = regexprep( handles.MultiechoName, '\.', '_');
    newpath = [handles.MultiechoPath tmppath...
        handles.MultiechoPath(end)];
elseif handles.MultiEcho.FileType == 6 %dicom data
    newpath = [handles.MultiechoPath 'AnalyzeNNLSData'...
        handles.MultiechoPath(end) ];
end
mkdir(newpath);
cd(newpath);
Filename = [handles.MultiechoName(1:end-4) '-' num2str(tmp(1)) ...
        num2str(tmp(2)) num2str(tmp(3)) '.roi'];
[file,path] = uiputfile(Filename,'Save file name');
cd(currentpath);
%check if user aborted
if file == 0
    return;
else
    save( [path,file(1:end-4),'.mat'], 'ROIline');
    %Change extension to .roi
    movefile([path,file(1:end-4),'.mat'], [path,file]);
    %
end
%

%Update handles
guidata(hObject,handles);
%

% -- End PushbuttonSaveROI


%% --- Executes on button press in PushButtonWindowLevel.
function PushButtonWindowLevel_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
%axes(handles.MRaxes);
if handles.MultiEcho.dim == 3
    imcontrast(handles.MRaxes);
elseif handles.MultiEcho.dim == 4
    imcontrast(handles.MRaxes);
end
% -- End PushbuttonWindowLevel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sliders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% --- Executes on slider movement that controls which slice is displayed
function SliderSlices_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
tmp = int16( get( hObject, 'Value' ) );
%check to see if the slider actually moved
if tmp ~= handles.SliceNumber
    set( hObject, 'Value', tmp )
    if length( handles.MultiEcho.size ) == 3  %only 1 slice
        set( hObject, 'Value', 1 )
    elseif length( handles.MultiEcho.size ) == 4 && ...
            handles.MultiEcho.size(4) == 1 
        set( hObject, 'Value', 1 )
    else
        set( handles.TotalSlicesTag, 'String', [ num2str( tmp ), ...
            ' of ', num2str( handles.MultiEcho.size(4) ) ] )
        %change slice number
        handles.SliceNumber = tmp;
        %plot new slice
        handles = PlotImage(handles);
        %update handles
        guidata(hObject,handles)
    end
end

% --- Executes during object creation, after setting all properties.
function SliderSlices_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to SliderSlices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




%% --- Executes on slider movement that controls what echo is displayd
function SliderEchoes_Callback(hObject, eventdata, handles) %#ok<INUSL,INUSD,DEFNU>
tmp = int16( get( hObject, 'Value' ) );
%check to see if slider actually moved <it might not due to rounding when
%users slide the slider instead of using the arrows>
if tmp ~= handles.EchoNumber
    %update slider
    set( hObject, 'Value', tmp )
    %change image
    handles.EchoNumber = tmp;
    tmpROI = handles.ROI.exists; %Store this flag  
    handles.ROI.exists = 0; %force flag to zero so that decay plot remains
    handles = PlotImage(handles);
    %Draw ROI if one exists
    if tmpROI
        handles.ROI.exists = tmpROI; %replace flag
        axes(handles.MRaxes)
        hold on
        handles.ROI.line = line(handles.ROI.xi,...
            handles.ROI.yi,'Color','red','LineWidth',1);
        hold off
    end
    %update echo viewed on GUI
    set( handles.TotalEchoesTag, 'String', [ num2str(tmp), ' of ', ...
        num2str( handles.MultiEcho.size(3) ) ] );
    %update gui
    guidata(hObject,handles)
end

% --- Executes during object creation, after setting all properties.
function SliderEchoes_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to SliderEchoes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end










%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Toggle Buttons
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- Executes on button press in ToggleButtonZoom.
function ToggleButtonZoom_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>

%Check if anything exists
if isempty(handles.MultiEcho.data)
    return;
end
%

%Does an ROI exist? If so, delete it before proceeding
if handles.ROI.exists == 1
    handles.ROI.exists = 0;
    delete(handles.ROI.line);
end
%

%zoom away
list = findobj(handles.MRaxes,'Type','uicontrol');

if get(hObject,'Value')
    %turn buttons as needed
    set( handles.PushbuttonLoadFile, 'Enable', 'off' )
    set( handles.PushbuttonLoadData, 'Enable', 'off' )
    set( handles.PushButtonWindowLevel, 'Enable', 'off' )
    set( handles.PushbuttonDrawROI, 'Enable', 'off' )
    set( handles.PushbuttonLoadROI, 'Enable', 'off' )
    set( handles.PushbuttonSaveROI, 'Enable', 'off' )
    set( handles.PushbuttonRunNNLS, 'Enable', 'off' )
    set( handles.PushbuttonSaveData, 'Enable', 'off' )
    %
    zoom on
    handles.ZoomOn = 1;
    set(list,'Enable','off');
    set(hObject,'Enable','on');
else
    %turn buttons as needed
    set( handles.PushbuttonLoadFile, 'Enable', 'on' )
    set( handles.PushbuttonLoadData, 'Enable', 'on' )
    set( handles.PushButtonWindowLevel, 'Enable', 'on' )
    set( handles.PushbuttonDrawROI, 'Enable', 'on' )
    set( handles.PushbuttonLoadROI, 'Enable', 'on' )
    set( handles.PushbuttonSaveROI, 'Enable', 'off' )
    set( handles.PushbuttonRunNNLS, 'Enable', 'off' )
    set( handles.PushbuttonSaveData, 'Enable', 'off' )
    %
    zoom off
    handles.ZoomOn = 0;
    set(list,'Enable','on');
end
%

%Update handles
guidata(hObject,handles);
%

% -- End ToggleButtonZoom

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function Calls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% --- LoadInformation
function handles = LoadInformation(hObject,handles)

%delete ROI variable if it exists
if exist('handles.ROI.exists', 'var')
    if handles.ROI.exists
        handles.ROI.exists = 0;
        %clear decay data
        if ishandle( handles.figures.figure_decay )        
            close( handles.figures.figure_decay )    
        end
        if ishandle( handles.figures.figure_resid )
            close( handles.figures.figure_resid )
        end
        if ishandle( handles.figures.figure_T2dist)
            close( handles.figures.figure_T2dist )
        end
    end
end
%

%clear echo times
handles.MultiEcho.te = [];
%

% display pathname and output dir in gui
set(handles.MultiEchoFileNameTag,'String',...
    [handles.MultiechoPath,handles.MultiechoName]);

%load file
if strcmpi( handles.MultiechoName(end-3:end), 'MEID')
    %MEID file
    [handles] = qT2_LoadMEID(hObject,handles);
elseif strcmpi( handles.MultiechoName(end-2:end), 'REC' )
    %Philips Case
    [handles] = qT2_readrec(hObject,handles);
elseif strcmpi( handles.MultiechoName(end-2:end), 'mat' )
    %Dunn Matlab case
    [handles] = qT2_LoadDunnData(hObject,handles);
    %te not in the file
    handles.MultiEcho.te = handles.FitParam.EchoSpacing:...
        handles.FitParam.EchoSpacing:...
        handles.FitParam.EchoSpacing*handles.MultiEcho.size(3);
elseif strcmpi( handles.MultiechoName(end-5:end), 'bff.gz' )
    %UBC bff Case
    [handles] = qT2_readbff(hObject,handles);
elseif strcmpi( handles.MultiechoName(end-2:end), 'fdf' )
    [handles] = qT2_LoadVarian(hObject,handles);
elseif handles.MultiechoName(1) == 'P'
    %GE P files
    [handles] = qT2_LoadPfiles(hObject,handles);
elseif strcmpi( handles.MultiechoName(end-2:end), 'dcm' )
    %dicom case
    [handles] = qT2_readDCM(hObject,handles);
else
    errordlg('Unknown File Type')
%    Files = 0; %#ok<NASGU> %only used for uigetfile
    return;
end
%

% %Scale Data by initial Echo
% handles.MultiEcho.data = abs(handles.MultiEcho.data);
% tmp = handles.MultiEcho.data(:,:,1);
% for i = 1:length( handles.MultiEcho.data(1,1,:) )
%     handles.MultiEcho.data(:,:,i) = ...
%         handles.MultiEcho.data(:,:,i) ./ tmp;
% end
% %threshold
% indicies = find(abs(handles.MultiEcho.data) > 2);
% for i = 1:length(indicies)
%     handles.MultiEcho.data( indicies(i) ) = 0;
% end
% handles.MultiEcho.data = handles.MultiEcho.data*10000;
% %

%Show first echo of data
handles = PlotImage(handles);
%

% set total nunber of slices on gui slider and in text  box beside slider
if length( handles.MultiEcho.size ) == 3  %only 1 slice
    set( handles.SliderSlices, 'Min', 1, 'Max', 2', 'SliderStep', ...
        [1 1], 'Value', 1 )
    set( handles.TotalSlicesTag, 'String', '1 of 1' )
else
    if handles.MultiEcho.size(4) == 1  %only 1 slice
        set( handles.SliderSlices, 'Min', 1, 'Max', 2', 'SliderStep', ...
            [1 1], 'Value', 1 )
        set( handles.TotalSlicesTag, 'String', '1 of 1' )
    else  %more than 1 slice
        set( handles.SliderSlices, 'Min', 1, 'Max', ...
            handles.MultiEcho.size(4), 'SliderStep', ...
            [1/(handles.MultiEcho.size(4)-1) ...
            2/(handles.MultiEcho.size(4)-1)], 'Value', 1 )
        set( handles.TotalSlicesTag, 'String', [ '1 of ', ...
            num2str( handles.MultiEcho.size(4) ) ] )
    end
end
%

%use te if in loaded file
if ~isempty( handles.MultiEcho.te )
    handles.FitParam.EchoSpacing = handles.MultiEcho.te(2)-handles.MultiEcho.te(1);
% Could use the code below to update the T2 basis range. But, it would 
%   over-ride user settings.
%    set( handles.EditTextT2min, 'String', ...
%        num2str( handles.MultiEcho.te(1)*1.5 ) );
%    set( handles.EditTextT2max, 'String', ...
%        num2str( handles.MultiEcho.te(end)*2 ) );
end
%

%display total number of echoes on GUI
set( handles.TotalEchoesTag, 'String', ['1 of ', ...
    num2str( handles.MultiEcho.size(3) ) ] );
%set total number of echoes on slider
set( handles.SliderEchoes, 'Min', 1, 'Max', handles.MultiEcho.size(3), ...
    'SliderStep', [1/(handles.MultiEcho.size(3) - 1) ...
    2/(handles.MultiEcho.size(3) - 1)], 'Value', 1 )
% % % % set( handles.SliderEchoes, 'Min', 1 );
% % % % set( handles.SliderEchoes, 'Max', handles.MultiEcho.size(3) );
% % % % set( handles.SliderEchoes, 'SliderStep', [ 1:handles.MultiEcho.size(3) 1] );
% % % % set( handles.SliderEchoes, 'Value', 1 );
%

% -- End LoadInformation

%% --- PlotDecay
function handles = PlotDecay(handles)
%clear figure if it exists already
if ishandle( handles.figures.figure_decay )        
    close( handles.figures.figure_decay )   
end
%Launch new window for plotting
handles.figures.figure_decay = figure(handles.figures.figure_decay);
axes( 'Parent', handles.figures.figure_decay, 'FontSize', 12, 'FontName',...
    'Times New Roman' )
set(handles.figures.figure_decay, 'Name','DecayData','Position',...
    [handles.scrsz(3)*3/4 handles.scrsz(4)*3/6 ...
    handles.scrsz(3)/4 handles.scrsz(4)*2/6] )
semilogy(handles.MultiEcho.te, handles.MultiEcho.meanData, 'o' )
axis( [0 max(handles.MultiEcho.te) ...
    min(handles.MultiEcho.meanData) max(handles.MultiEcho.meanData)] )
title( 'Multiecho Decay Curve', 'FontWeight','bold','FontSize',12,...
    'FontName','Times New Roman' );
xlabel( 'time (ms)', 'FontSize', 12, 'FontName', 'Times New Roman' )
ylabel( 'amp (arb)', 'FontSize', 12, 'FontName', 'Times New Roman' )
legend( 'Measured Data' )
% -- End PlotDecay

%% --- PlotFit
function handles = PlotFit(handles)
%Put fit into launched figure window
figure(handles.figures.figure_decay)
hold on
semilogy( handles.Fit.te, ...
    handles.y_recon, 'k-', 'Linewidth', 2 )
hold off
legend( 'Measured Data','Fit' )
% -- End PlotFit

%% --- PlotImage
function handles = PlotImage(handles)

%Clear ROI flag if it exists, and we are not just changing echoes
if handles.ROI.exists == 1
    handles.ROI.exists = 0;
    %clear decay data
    if ishandle( handles.figures.figure_decay )        
        close( handles.figures.figure_decay )   
    end
    if ishandle( handles.figures.figure_resid )
        close( handles.figures.figure_resid )
    end
    if ishandle( handles.figures.figure_T2dist)
        close( handles.figures.figure_T2dist )
    end
end

axes(handles.MRaxes);
cla;
if length( handles.MultiEcho.size ) == 3 
    if handles.ComplexFlag == 0 %abs data
        imagesc( abs( ...
            handles.MultiEcho.data( 1:end, 1:end, handles.EchoNumber ) ) );
    elseif handles.ComplexFlag == 1 %real valued complex data
        imagesc( real( ...
            handles.MultiEcho.data( 1:end, 1:end, ...
            handles.EchoNumber ) ) ); %for complex data
    else
        'handles.Multiecho.DataType variable clash 1' %#ok<NOPRT>
    end
else
    if handles.ComplexFlag == 0 %abs data
        imagesc( abs( ...
            handles.MultiEcho.data( 1:end, 1:end,...
            handles.EchoNumber,handles.SliceNumber ) ) );
    elseif handles.ComplexFlag == 1 %real valued complex data
        imagesc( real( ...
            handles.MultiEcho.data( 1:end, 1:end,...
            handles.EchoNumber,handles.SliceNumber ) ) ); %for complex data
        else
        'handles.Multiecho.DataType variable clash 2' %#ok<NOPRT>
    end
end
colormap( gray(256) );
axis off;
set(0,'Units','Pixels');
%s = get(0,'ScreenSize');
%set(gca,'DataAspectRatio',[s(4)/s(3) .75 .75]);   
% -- End PlotImage

%% --- PlotResiduals
function handles = PlotResiduals(handles, resid)
%clear figure if it exists already
if ishandle( handles.figures.figure_resid )        
    close( handles.figures.figure_resid )   
end
%Launch new window for plotting
handles.figures.figure_resid = figure(handles.figures.figure_resid);
axes( 'Parent', handles.figures.figure_resid, 'FontSize', 12, 'FontName',...
    'Times New Roman' )
set( handles.figures.figure_resid, 'Name','Residuals','Position',...
     [handles.scrsz(3)*3/4 handles.scrsz(4)*3/8 ...
     handles.scrsz(3)/4 handles.scrsz(4)*1/7])
plot( handles.Fit.te, resid, 'k-', 'Linewidth', 2 )
axis( [0 max(handles.MultiEcho.te) min(resid) max(resid)] )
title('Residuals', 'FontWeight','bold','FontSize',12,...
    'FontName','Times New Roman' )
xlabel( 'time (ms)', 'FontSize', 12, 'FontName', 'Times New Roman' )
ylabel( 'amp (arb)', 'FontSize', 12, 'FontName', 'Times New Roman' )
legend( 'Residuals' )
% -- EndPlotResiduals

%% --- PlotT2Dist
function handles = PlotT2Dist(handles)
%clear figure if it exists already
if ishandle( handles.figures.figure_T2dist )        
    close( handles.figures.figure_T2dist )   
end
%Launch new window for plotting
handles.figures.figure_T2dist = figure(handles.figures.figure_T2dist);
axes( 'Parent', handles.figures.figure_T2dist, 'FontSize', 12, 'FontName',...
    'Times New Roman' )
set( handles.figures.figure_T2dist, 'Name','T2Dist','Position',...
     [handles.scrsz(3)*3/4 0 handles.scrsz(3)/4 ...
     handles.scrsz(4)*2/6])
 
semilogx( handles.NNLS.T2Basis, handles.NNLS.amplitudes, 'k-', ...
    'Linewidth', 2 )
xlabel('T_2 (ms)', 'FontSize', 12, 'FontName', 'Times New Roman' );
ylabel('Amplitude (arb)', 'FontSize', 12, 'FontName', 'Times New Roman' );
title('T_2 Distribution', 'FontWeight','bold','FontSize',12,...
    'FontName','Times New Roman')
xlim( [handles.FitParam.T2Min handles.FitParam.T2Max] )
ylim( [0 max(handles.NNLS.amplitudes)] )
%Add integral
hold on
plot( handles.NNLS.T2Basis, handles.NNLS.T2int, 'b--', ...
    'LineWidth', 2 )
hold off
legend('T_2 Distirbution', 'Integral', 'Location', 'East')
% -- EndPlotT2Dist


%% --- T2RegionAttributes
function T2RegionAttributes

%get handle
hAnalyzennlsGUI = getappdata( 0, 'hAnalyzennlsGUI' );
%get function handle to Total area of the T2 dist. This value can only be
%calculated if the fitting routine was run.
T2TotalArea = getappdata( hAnalyzennlsGUI, 'T2TotalArea' );
% are we ready for this?
if isempty( T2TotalArea )
    return;
end
%

%get region we are interested in, T2 dist, basis, and total area
RegionFlag = getappdata( hAnalyzennlsGUI, 'RegionFlag' );
T2amps = getappdata( hAnalyzennlsGUI, 'T2amps' );
T2Basis = getappdata( hAnalyzennlsGUI, 'T2Basis' );
%

%
if RegionFlag == 1
    minval = getappdata( hAnalyzennlsGUI, 'min1' );
    maxval = getappdata( hAnalyzennlsGUI, 'max1' );
elseif RegionFlag == 2
    minval = getappdata( hAnalyzennlsGUI, 'min2' );
    maxval = getappdata( hAnalyzennlsGUI, 'max2' );
elseif RegionFlag == 3
    minval = getappdata( hAnalyzennlsGUI, 'min3' );
    maxval = getappdata( hAnalyzennlsGUI, 'max3' );
end
%

if maxval > minval
    %determine regional fraction, region width, and GMT2
    if ( RegionFlag == 1 ) || ( RegionFlag == 2 )  %Region 1 and 2 don't
                                                   %include upper range
        %Area within the specified region
        range = T2Basis >= minval & T2Basis < maxval;
        T2BasisRange = T2Basis(range);
        T2ampsRange = T2amps(range);
        RegionFraction = sum( T2ampsRange ) / T2TotalArea;
        %Geometric mean T2 within the specified region
        GeoMeanRegionT2 = exp( dot( T2ampsRange, ...
            log( T2BasisRange ) ) ./ ...
            ( RegionFraction*T2TotalArea ) );
        %width of peaks in specified region
        if sum(T2ampsRange) == 0 %this measure does not exist
            gmT2Ratio = 0;
        else
            [MaxAmp, MaxIndex] = max( T2ampsRange );
            %Walk left
            i = MaxIndex;
            flag = 0; %when flag is 1, we exceed have found the FWHM
            if i == 1 %MaxIndex = Left T2
                LeftT2 = T2Basis(i);
            else
                while (i >= 1) && (flag == 0)
                    if i == 1 %MaxIndex = LeftT2
                        LeftT2 = T2BasisRange(i);
                    elseif T2ampsRange(i) < MaxAmp / 2
                        LeftT2 = T2BasisRange(i);
                        flag = 1;
                    end
                    i = i-1;
                end
            end
            %Walk right
            i = MaxIndex;
            flag = 0;
            if i == max(size(T2BasisRange)) %MaxIndex = RightT2
                RightT2 = T2BasisRange(i);
            else
                while (i <= max(size(T2BasisRange))) && (flag == 0)
                    if i == max(size(T2BasisRange)) %MaxIndex = RightT2
                        RightT2 = T2BasisRange(i);
                    elseif T2ampsRange(i) < MaxAmp / 2
                        RightT2 = T2BasisRange(i-1);
                        flag = 1;
                    end
                    i = i+1;
                end
            end
            gmT2Ratio = RightT2/LeftT2;
        end
        %        
    elseif RegionFlag == 3 %Region 3 includes upper bound in calculation
                           %(Often considered CSF)
                           % the '<=' operation does not work all the time
                           % because of machine precision differences
        %Area within the specified region
        range = ( T2Basis >= minval & T2Basis <= maxval ) | ...
            ( abs(T2Basis - maxval) < T2Basis(end)/10^6 ...
            & abs(T2Basis - maxval) > 0 ) ;
        T2BasisRange = T2Basis(range);
        T2ampsRange = T2amps(range);
        RegionFraction = sum( T2ampsRange )...
            ./ T2TotalArea;
        %Geometric mean T2 within the specified region
        GeoMeanRegionT2 = exp( dot( T2ampsRange, ...
            log( T2BasisRange ) ) ./ ...
            ( RegionFraction*T2TotalArea ) );
        %width of peaks in specified region
        if sum(T2ampsRange) == 0 %this measure does not exist
            gmT2Ratio = 0;
        else
            [MaxAmp, MaxIndex] = max( T2ampsRange );
            %Walk left
            i = MaxIndex;
            flag = 0; %when flag is 1, we exceed have found the FWHM
            if i == 1 %MaxIndex = Left T2
                LeftT2 = T2Basis(i);
            else
                while (i >= 1) && (flag == 0)
                    if i == 1 %MaxIndex = LeftT2
                        LeftT2 = T2BasisRange(i);
                    elseif T2ampsRange(i) < MaxAmp / 2
                        LeftT2 = T2BasisRange(i);
                        flag = 1;
                    end
                    i = i-1;
                end
            end
            %Walk right
            i = MaxIndex;
            flag = 0;
            if i == max(size(T2BasisRange)) %MaxIndex = RightT2
                RightT2 = T2BasisRange(i);
            else
                while (i <= max(size(T2BasisRange))) && (flag == 0)
                    if i == max(size(T2BasisRange)) %MaxIndex = RightT2
                        RightT2 = T2BasisRange(i);
                    elseif T2ampsRange(i) < MaxAmp / 2
                        RightT2 = T2BasisRange(i-1);
                        flag = 1;
                    end
                    i = i+1;
                end
            end
            %
            gmT2Ratio = RightT2/LeftT2;
        end
    end
    %
else %minval is > maxval. Set ans to -1, which is impossible
    RegionFraction = -1;
    GeoMeanRegionT2 = -1;
    gmT2Ratio = -1;
end

%store values
if RegionFlag == 1
    setappdata( hAnalyzennlsGUI, 'Region1Fraction', RegionFraction )
    setappdata( hAnalyzennlsGUI, 'Region1gmT2', GeoMeanRegionT2 )
    setappdata( hAnalyzennlsGUI, 'Region1W', gmT2Ratio )
elseif RegionFlag == 2
    setappdata( hAnalyzennlsGUI, 'Region2Fraction', RegionFraction )
    setappdata( hAnalyzennlsGUI, 'Region2gmT2', GeoMeanRegionT2 )
    setappdata( hAnalyzennlsGUI, 'Region2W', gmT2Ratio )
elseif RegionFlag == 3
    setappdata( hAnalyzennlsGUI, 'Region3Fraction', RegionFraction )
    setappdata( hAnalyzennlsGUI, 'Region3gmT2', GeoMeanRegionT2 )
    setappdata( hAnalyzennlsGUI, 'Region3W', gmT2Ratio )
end
%
% -- End T2RegionAttributes

%% --- UseROI
function handles = UseROI(handles)

%Determine average decay values and noise threshold
if length( handles.MultiEcho.size ) == 3 
    %Single Slice case
    %reshape data
    if handles.ComplexFlag == 0 %abs data
        tempdata = reshape( abs( handles.MultiEcho.data ), ...
            size(handles.MultiEcho.data,1)*size(handles.MultiEcho.data,2),...
            size(handles.MultiEcho.data,3) );
    elseif handles.ComplexFlag == 1 %real valued complex data
            tempdata = reshape( real( handles.MultiEcho.data ), ...
                size(handles.MultiEcho.data,1)*size(handles.MultiEcho.data,2),...
                size(handles.MultiEcho.data,3) ); %for complex data
    else
        'handles.Multiecho.DataType variable clash 3' %#ok<NOPRT>
    end
    %determine decay
    handles.MultiEcho.meanData = mean( tempdata( handles.ROI.indicies, :));
    handles.MultiEcho.stdData = std( double( tempdata( ...
        handles.ROI.indicies, : ) ) );
else
    %MultiSlice case
    %reshape data
    if handles.ComplexFlag == 0 %abs data
        tempdata = reshape( ...
            abs( handles.MultiEcho.data(:,:,:,handles.SliceNumber) ), ...
            size(handles.MultiEcho.data,1)*size(handles.MultiEcho.data,2), ...
            size(handles.MultiEcho.data,3) );
    elseif handles.ComplexFlag == 1 %real valued complex data
        tempdata = reshape( ...
            real( handles.MultiEcho.data(:,:,:,handles.SliceNumber) ), ...
            size(handles.MultiEcho.data,1)*size(handles.MultiEcho.data,2), ...
            size(handles.MultiEcho.data,3) ); %for complex data
    else
        'handles.Multiecho.DataType variable clash 4' %#ok<NOPRT>
    end
    %determine decay
    handles.MultiEcho.meanData = mean( tempdata( ...
        handles.ROI.indicies, : ) );
    handles.MultiEcho.stdData = std( double( tempdata( ...
        handles.ROI.indicies, : )));
end
%


%determine noise threshold
handles.NoiseThresh = mean( [ mean( tempdata( 1,:) ) ...
    mean( tempdata( size(handles.MultiEcho.data,1),: ) ) ...
    mean( tempdata( size(handles.MultiEcho.data,1)*...
    size(handles.MultiEcho.data,2)-...
    size(handles.MultiEcho.data,1)+1, : ) ) ...
    mean( tempdata( size(handles.MultiEcho.data,1)*...
    size(handles.MultiEcho.data,2), : ) ) ] );
%

%create echo times if needed
if isempty( handles.MultiEcho.te )
    handles.MultiEcho.te = handles.FitParam.EchoSpacing:handles.FitParam.EchoSpacing: ...
        handles.FitParam.EchoSpacing*size(handles.MultiEcho.meanData,2);
end
%

%plot Data
handles = PlotDecay(handles);
%

%Clear other figures
if ishandle( handles.figures.figure_T2dist)
    close( handles.figures.figure_T2dist )
end
if ishandle( handles.figures.figure_resid )
    close( handles.figures.figure_resid )
end
%
% -- End UseROI  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%



%%%%
% Command to build executable on Windows:
% mcc -v -m AnalyzeNNLS
%
% Be sure to include files from the Library including (2007.04.17)
%
% When installing on on a virgin machine, be sure to include the
% MRCInstaller. This exe is required in order for a computer without Matlab
% to run AnalyzeNNLS.
% - C:\Program Files\MATLAB71\toolbox\compiler\deploy\win32\MCRInstaller.exe
%
% Note: DC offset calculated, but not used in area calculations
% %%%%% Remember to change file opening method for windows
%%%%
 



