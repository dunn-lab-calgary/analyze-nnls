%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2009.03.05 Last modified 2009.03.05
%
% TNT2MEID.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assumptions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Derived from:
%  Read_SSME_img: 
%  Single-Slice-Multi-Echo (MSME) , NTNMR binary file(*.tnt),obtained from
%  ASPECT 1T system. 
%---------------------------------------------------------------------------
% Seong Min Kim, Chonbuk National University, 05/29/2008
% Modified by Michael J. McCarthy, UC, Davis, 03/02/2009
% Modified by Mecit Halil Oztop, UC, Davis,   03/02/2009
%--------------------------------------------------------------------------
%
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



clear all

%%%%%Header Information%%%%%%

%Initialize data
MEID.ver = '0.3';
MEID.nrows = 128; %ideally determined from the data 
MEID.ncols = 128; %ideally determined from the data  
MEID.nslices = 1; %ideally determined from the data  
MEID.nechoes = 32; %ideally determined from the data  
MEID.TR = 0;
MEID.echo_times = 10:10:MEID.nechoes*10; %ideally determined from the data   
MEID.FOV = 0; 
MEID.naverages = 0; 
MEID.slice_thickness = 0;
MEID.acquired = '';
MEID.byte_order = '';
%


%---------------------------------------------------------------------------
%/// open and read data file //////
%
[fn,pn] = uigetfile( ...
{'*.tnt', 'NTNMR Image data file (*.tnt)';'*.*',  'All Files (*.*)'},...
'Pick a file','MultiSelect','on');


fnp=[pn fn];
[p f ext] = fileparts(fnp);


%%%%%%%%%%%%%%%%%%% open data file %%%%%%%%%%%%%%%%%%%%%%%% 
fid=fopen(fnp);  
% read Saturation Recovery parameters
fseek(fid,36,0); %skip to read points requested 1D, 2D, 3D, 4D
npts=fread(fid,4,'long');
fprintf('No. of point: 1D=%8d, 2D=%8d,3D=%8d,4D=%8d\n',npts(1),npts(2),npts(3),npts(4));
frewind(fid);
fseek(fid,52,0); %skip to read acquisition data point
acq_p=fread(fid,1,'long');
fprintf('acq_P=%4d\n',acq_p);
points = prod(npts);
% points = 128*32*4*128;

% read image data
frewind(fid);
fseek(fid,1056,0); %skip header information, 1056 bytes
%MRI_im=fread(fid,2*npts(1)*npts(2),'float32'); % read real & imaginary data
MRI_im=fread(fid,2*points,'float32'); % read real & imaginary data

%m1=fread(fid,[m_mrd,n_mrd],'short');

fclose(fid);  

m1=MRI_im;



% The data file needs to be sorted into the real and imaginary parts 
% for FT processing.  The data are in pairs, (real,imag) etc..
ir=1:2:(2*points-1);  %% index for the real data
ii=2:2:(2*points);    %% index for the imaginary data
wa=m1(ir,:)+sqrt(-1)*m1(ii,:);
ssme = reshape(wa,128,32,128);
figure, imagesc(abs(fftshift(fftn(squeeze(ssme(:,1,:))))));
figure,
for i=1:32, subplot(8,4,i), imagesc(abs(fftshift(fftn(squeeze(ssme(:,i,:)))))), end;



%Create MEID data
MEID.DATA = zeros(MEID.nrows, MEID.ncols, MEID.nechoes);
for i = 1:MEID.nechoes
    MEID.DATA(:,:,i) = fftshift( fftn( squeeze( ssme(:,i,:) ) ) );
end
%


%%%%%Write out Data%%%%%%%

%Save matlab format data
MEID.directory = pn;
MEID.filename = fn(1:end-4);
save( [MEID.directory, MEID.filename, '.mat' ], 'MEID' );
movefile( [ MEID.directory, MEID.filename, '.mat'], ...
    [ MEID.directory, MEID.filename, '_MEID.MEID' ] );
%

%{
clear; clc;

%parse Header for relavant information
%To do
%

%Hardcode in the path for now
directory = 't2_mc_32_6/';
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
%}