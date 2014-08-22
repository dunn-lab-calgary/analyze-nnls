%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2010.07.20  Last modified 2010.07.20
%
% qT2_readDCM.m
%
% Special thank you to Elena Olariu for providing a sample multiecho dcm
% dataset.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - This function reads dcm <dicom> qT2 data
% - Assumes the folder contains one single slice multiecho dataset in dicom
% format. Also assuming that the files have .dcm extention and have
% filenames that cause the data to be ordered consecutively with echo
% spacing
% - any dcm file can be chosen, this function finds the rest
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:   
%{
    clear;
    %Inital values
    handles.MultiechoPath = '';
    handles.MultiechoName = 'TE_0004.dcm';
    %
    %Load Data
    [handles] = qT2_readDCM('0',handles);
    %

%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dependencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - standard Matlab dependencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables and Descriptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Variables:
% - hObject = original figure handle
% - h. = input handles. There can be many of these depending on the calling
%      function. Only 2 are needed
%    MultiechoPath = path to file that needs opening
%    MulitechoName = name of file that needs opening
%Return Variables:
% - h. = output handles. New information is added to this structure.
%    MultiEcho.
%        data = actual raw data, reordered to proper dimensions
%        DataType = 1 for real, 0 for complex.
%        dim = image dimensions
%        FOV = field of view in cm (zeros if not stated)
%        size = number of image dimensions present (x,y,time,slice)
%        te = echo times that the data was collected at (zeros if not
%          stated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin function qT2_LoadMEID


function [h] = qT2_readDCM(hObject,h)

%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end

%%%%%Header Information%%%%%%


%Initialize data
h.MultiEcho.acquired = '';
h.MultiEcho.byte_order = '';
h.MultiEcho.data = 0;
h.MultiEcho.DataType = 1; %1 for real, 0 for complex
h.MultiEcho.dim = 0;
h.MultiEcho.FOV = 0;
h.MultiEcho.naverages = 0; 
h.MultiEcho.nrows = 0; 
h.MultiEcho.ncols = 0; 
h.MultiEcho.nslices = 0; 
h.MultiEcho.nechoes = 0; 
h.MultiEcho.size = 0;
h.MultiEcho.slice_thickness = 0;
h.MultiEcho.te = 0;
h.MultiEcho.TR = 0;
%
    

%Get files in the directory
Files = dir( [ h.MultiechoPath,'*.dcm' ] );
%


%open first file
%get dicom header information
info = dicominfo( [h.MultiechoPath, Files(1).name] );
%

%set some header information
h.MultiEcho.nrows = info.Rows;
h.MultiEcho.ncols = info.Columns;
h.MultiEcho.nslices = 1; %hardcoded in for now
h.MultiEcho.nechoes = length(Files)-3;
h.MultiEcho.TR = info.RepetitionTime; %in ms
h.MultiEcho.naverages = info.NumberOfAverages;
h.MultiEcho.slice_thickness = info.SliceThickness;
h.MultiEcho.acquired = info.AcquisitionDate;
h.MultiEcho.byte_order = 'l'; %Hardcode to little endian for now
h.MultiEcho.FOV = [info.PixelSpacing(1)*h.MultiEcho.ncols/10 ...
    info.PixelSpacing(2)*h.MultiEcho.nrows/10]; %in cm x cm
%
%%%%%End Header Information%%%%%%


%%%%%MultiEcho Data %%%%%%
%preallocate for speed
hbar = waitbar(0,''); set(findall(hbar,'type','text'),...
    'Interpreter','none', 'string', sprintf('Loading dicom file'));
h.MultiEcho.data = zeros(h.MultiEcho.nrows, h.MultiEcho.ncols, ...
    length(Files));
for i = 1:length(Files)
    h.MultiEcho.data(:,:,i) = ...
        double( dicomread( [h.MultiechoPath, Files(i).name] ) );
    info = dicominfo( [h.MultiechoPath, Files(i).name] );
    h.MultiEcho.te(i) = info.EchoTime;
    if mod(i,5) == 0
        waitbar(i/length(Files),hbar)
    end
end
%
close(hbar);

%%%%%End MultiEcho Data %%%%%%

% Other useful parameters
h.MultiEcho.dim = length(size(h.MultiEcho.data));
h.MultiEcho.size = size(h.MultiEcho.data);
h.MultiEcho.DataType = isreal(h.MultiEcho.data); 
%1 for real, 0 for complex
%

if hObject ~= '0'
    %gui case
    %Update handles
    guidata(hObject,h);
    %
end


%end Function qT2_readDCM


