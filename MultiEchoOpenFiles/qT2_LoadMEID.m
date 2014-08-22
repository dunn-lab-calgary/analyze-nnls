%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2007.06.21  Last modified 2007.06.26
%
% qT2_LoadMEID.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - This function loads MEID qT2 data
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:   NOT DONE
%{
    clear;
    %Inital values
    handles.MultiechoPath = '';
    handles.MultiechoName = '040903-56.HB1_128echo.MEID';
    %
    %Load Data
    [handles] = qT2_LoadMEID('0',handles);
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


function [h] = qT2_LoadMEID(hObject,h)


%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end

%load file
movefile( [ h.MultiechoPath, h.MultiechoName], ...
    [ h.MultiechoPath, h.MultiechoName(1:end-5), '.mat' ] );
load( [ h.MultiechoPath, h.MultiechoName(1:end-5), '.mat' ] );
movefile( [ h.MultiechoPath, h.MultiechoName(1:end-5), '.mat' ], ...
    [ h.MultiechoPath, h.MultiechoName] );
%

%Set handles
if hObject == '0'
    %non-gui case
    %Assign to handles
    h.MultiEcho.dim = length( size( MEID.DATA ) );  
    h.MultiEcho.FOV = MEID.FOV;
    if h.MultiEcho.dim == 3
        h.MultiEcho.FOV = [ h.MultiEcho.FOV 0 ];
    end
    h.MultiEcho.te = MEID.echo_times;
    h.MultiEcho.data = MEID.DATA;
    h.MultiEcho.size = [ MEID.nrows MEID.ncols MEID.nechoes MEID.nslices ]; %Will the nslices still work for single slice?
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(MEID.DATA);
else
    %gui case
    %Assign to handles
    h.MultiEcho.dim = length( size( MEID.DATA ) );
    h.MultiEcho.FOV = MEID.FOV;
    if h.MultiEcho.dim == 3
        h.MultiEcho.FOV = [ h.MultiEcho.FOV 0 ];
    end
    h.MultiEcho.te = MEID.echo_times;
    h.MultiEcho.data = MEID.DATA;
    h.MultiEcho.size = [ MEID.nrows MEID.ncols MEID.nechoes MEID.nslices];
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(MEID.DATA);
    %Update handles
    guidata(hObject,h);
    %
end
%

%end Function qT2_LoadMEID

