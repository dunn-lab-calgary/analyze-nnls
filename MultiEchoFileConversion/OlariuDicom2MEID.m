%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2009.01.14 Last modified 2009.01.16
%
% OlariuDicom2MEID.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assumptions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - 
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dependencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - standard Matlab dependencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables and Descriptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Input Variables:
% - 
%Return Variables:
% - 
%Internal Variables:
% - 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

%parse Header for relavant information
%To do
%

%Hardcode in the path for now
directory = 'Stys-SRC2012-01-004.f71/11/';
MEID.directory = '';
MEID.filename = directory(1:end-1); 
%output filename is the same as the original directory name


%%%%%Header Information%%%%%%

%Initialize data
MEID.ver = '0.3';
MEID.nrows = 0; 
MEID.ncols = 0; 
MEID.nslices = 0; 
MEID.nechoes = 0; 
MEID.TR = 0;
MEID.echo_times = 0; 
MEID.FOV = 0; 
MEID.naverages = 0; 
MEID.slice_thickness = 0;
MEID.acquired = '';
MEID.byte_order = '';
%

%Get files in the directory
Files = dir( [ directory,'*.dcm' ] );
%

%open first file
%get dicom header information
info = dicominfo( [directory, Files(1).name] );
%

%set some MEID header information
MEID.nrows = info.Rows;
MEID.ncols = info.Columns;
MEID.nslices = 1; %hardcoded in for now
MEID.nechoes = length(Files)-3;
MEID.TR = info.RepetitionTime; %in ms
MEID.naverages = info.NumberOfAverages;
MEID.slice_thickness = info.SliceThickness;
MEID.acquired = info.AcquisitionDate;
MEID.byte_order = 'l'; %Hardcode to little endian for now
MEID.FOV = [info.PixelSpacing(1)*MEID.ncols/10 ...
    info.PixelSpacing(2)*MEID.nrows/10]; %in cm x cm
%

%%%%%End Header Information%%%%%%


%%%%%MultiEcho Data %%%%%%
%Read in data, first 3 sets ignored as per request
%preallocate for speed
MEID.DATA = zeros(MEID.nrows, MEID.ncols, length(Files)-3);
for i = 1:length(Files)-3
    MEID.DATA(:,:,i) = double( dicomread( [directory, Files(i).name] ) );
    info = dicominfo( [directory, Files(i).name] );
    MEID.echo_times(i) = info.EchoTime;
end
%
%%%%%End MultiEcho Data %%%%%%

%Plot for sanity check
figure(1);
imagesc( abs( MEID.DATA(:,:,1) ) ); colormap(gray); colorbar;
figure(2);
imagesc( abs( MEID.DATA(:,:,end) ) ); colormap(gray); colorbar;
%

%%%%%Write out Data%%%%%%%

% 
%Save matlab format data
save( [MEID.directory, MEID.filename, '.mat' ], 'MEID' );
movefile( [ MEID.directory, MEID.filename, '.mat'], ...
    [ MEID.directory, MEID.filename, '_MEID.MEID' ] );
%



