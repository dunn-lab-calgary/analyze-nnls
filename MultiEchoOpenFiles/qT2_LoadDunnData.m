%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2007.01.10  Last modified 2008.05.26
%
% qT2_LoadDunnData.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - This function load's Dunn's qT2 matlab formatted data
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:   NOT DONE
%{
    clear;
    %Inital values
    handles.MultiechoPath = [''];
    handles.MultiechoName = 'T2phantoms.mat';
    %
    %Load Data
    [handles] = qT2_LoadDunnData('0',handles);
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
%        dir_name = unsure, not used
%        domain = unsure, not used
%        FOV = field of view in cm (zeros if not stated)
%        hz_ppm = unsure, not used
%        size = number of image dimensions present (x,y,time,slice)
%        te = echo times that the data was collected at (zeros if not
%          stated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin function qT2_LoadDunnData


function [h] = qT2_LoadDunnData(hObject,h)

%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end


if hObject == '0'
    %non-gui case
    %load file
    load([h.MultiechoPath,h.MultiechoName]);
    %Assign to handles
    h.MultiEcho.dim = DIM;
    h.MultiEcho.size = SIZE;
    h.MultiEcho.dir_name = DIR_NAME;
    h.MultiEcho.FOV = FOV;
    h.MultiEcho.domain = DOMAIN;
    h.MultiEcho.hz_ppm = HZ_PPM;
    h.MultiEcho.data = reshape( DATA, SIZE );
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(DATA);
    %echo times not stated in these files
    h.MultiEcho.te(1:h.MultiEcho.size(3)) = 0;
else
    %gui case
    %load file
    load([h.MultiechoPath,h.MultiechoName]);
    %Assign to handles
    h.MultiEcho.dim = DIM;
    h.MultiEcho.size = SIZE;
    h.MultiEcho.dir_name = DIR_NAME;
    h.MultiEcho.FOV = FOV;
    h.MultiEcho.domain = DOMAIN;
    h.MultiEcho.hz_ppm = HZ_PPM;
    h.MultiEcho.data = reshape( DATA, SIZE );
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(DATA);
    %echo times not stated in these files
    h.MultiEcho.te(1:h.MultiEcho.size(3)) = 0;
    %Update handles
    guidata(hObject,h);
    %
end

%end Function qT2_LoadDunnData

