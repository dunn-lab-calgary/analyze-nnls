%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2008.11.27  Last modified 2008.12.12
%
% qT2_LoadVarian.m
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
    handles.MultiechoPath = ['sems_005.img/'];
    handles.MultiechoName = 'slice001image008echo001.fdf';
    %
    %Load Data
    [handles] = qT2_LoadVarian('0',handles);
    %

%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dependencies
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - standard Matlab dependencies
% - Assuming constant echo time and first echo time is equal to echo
% spacing
% - Assuming folder is filled with *.fdf along with one procpar. User can
% open any single fdf file and all fdf files will be opened
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
%        dim = data dimensions (eg 3)
%        FOV = field of view in cm (zeros if not stated)
%        size = number of image dimensions present (x,y,time,slice)
%        te = echo times that the data was collected at (zeros if not
%          stated)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Begin function qT2_LoadMEID


function [h] = qT2_LoadVarian(hObject,h)

%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end


% What files exist? I am assuming that all the *fdf files need to be
% opened.
files = dir( [h.MultiechoPath, '*.fdf' ]);
%

%rename file to folder name
h.MultiechoName = h.MultiechoPath(1:end-1);


% if data is 'mems', it is multiecho data. If the data are 'sems' they are
% multiple images instead of multiple echoes and need to be handled
% differently.
if strcmpi( h.MultiechoPath(end-12:end-9), 'mems' )
    % Load mems Data
    % open first file and extract headerinformation
    [ DataTmp, Header ] = ...
            qT2_Varian_fdf( h.MultiechoPath, files(1).name );
    for j=1:length(Header) %pull out TE, FOV, and image size
        if( length(Header{j}) > 13 && ...
                strcmp(Header{j}(1:13), 'float  span[]') == 1 )
            h.MultiEcho.FOV = str2num( Header{j}(18:end-2) ); %#ok<ST2NM>
        elseif( length(Header{j}) > 9 && ...
                strcmp(Header{j}(1:9), 'float  TE') == 1 )
            h.MultiEcho.te(1) = str2double( Header{j}(13:end-1) );
        elseif ( length(Header{j}) > 13 && ...
                strcmp(Header{j}(1:15), 'float  matrix[]') == 1 )
            sizeTmp = str2num( Header{j}(20:end-2) ); %#ok<ST2NM>
        end
    end
    %
    % prealocate for speed.
    h.MultiEcho.data = zeros( sizeTmp(1), sizeTmp(2), length(files)-3 ); 
    h.MultiEcho.data(:,:,1) = DataTmp;
    clear DataTmp sizeTmp
    %
    % Load the rest of the data
    for i = 2:length(files)
        [ h.MultiEcho.data(:,:,i), Header ] = ...
            qT2_Varian_fdf( h.MultiechoPath, files(i).name );
        for j=1:length(Header) %pull out TE
            if( length(Header{j}) > 9 && ...
                    strcmp(Header{j}(1:9), 'float  TE') == 1 )
                h.MultiEcho.te(i) = str2double( Header{j}(13:end-1) );
            end
        end
    end
    %
elseif strcmpi( h.MultiechoPath(end-12:end-9), 'sems' )
    % Load sems Data
    % open first file and extract header information
    [ DataTmp, Header ] = ...
            qT2_Varian_fdf( h.MultiechoPath, files(1).name );
    for j=1:length(Header) %pull out TE, FOV, and image size
        if( length(Header{j}) > 13 && ...
                strcmp(Header{j}(1:13), 'float  span[]') == 1 )
            h.MultiEcho.FOV = str2num( Header{j}(18:end-2) ); %#ok<ST2NM>
        elseif ( length(Header{j}) > 13 && ...
                strcmp(Header{j}(1:15), 'float  matrix[]') == 1 )
            sizeTmp = str2num( Header{j}(20:end-2) ); %#ok<ST2NM>
        end
    end
    %
    % prealocate for speed.
    h.MultiEcho.data = zeros( sizeTmp(1), sizeTmp(2), length(files)-3 ); 
    h.MultiEcho.data(:,:,1) = DataTmp;
    clear DataTmp sizeTmp
    %
    % Load the rest of the data
    for i = 2:length(files)
        [ h.MultiEcho.data(:,:,i), Header ] = ...
            qT2_Varian_fdf( h.MultiechoPath, files(i).name ); %#ok<NASGU>
    end
    %
    %te is stored in the procpar file
    Header = textread( [ h.MultiechoPath, 'procpar' ] , '%s', ...
        'delimiter', '\n' );
    for i = 1:length(Header)
        if( length(Header{i}) > 2 && strcmp(Header{i}(1:2), 'te') )
            h.MultiEcho.te = str2num( Header{i+1} ); %#ok<ST2NM>
            %first value is total number of echoes, I can discard it
            h.MultiEcho.te = 1000*h.MultiEcho.te(2:end); 
        end
    end
    %
else
    error( [ 'I do not recognize the file format as sems or mems. I ', ...
        'will now crash. Please report issue to ', ...
        'http://sourceforge.net/projects/analyzennls/' ] )
end
    

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

%end Function qT2_LoadVarian

