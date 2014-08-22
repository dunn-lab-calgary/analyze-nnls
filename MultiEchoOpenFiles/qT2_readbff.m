function h = qT2_readbff(hObject,h)
%
% h = readbff(filename, type)
%
% Description:
%      Reads in a BFF file and outputs the data matrix
%      and the header information.
%
% Output:
%      h: AnalyzeNNLS multiecho information
% 
% Input:
%      filename: full filename including path
%      type: optional parameter, default 'uint16'
%
% External Calls:
%      none
%
% Toolbox:
%      MATLAB
%
%      Created by Michael Yalowsky
%      yalowsky@interchange.ubc.ca
%      April 2003
%
% Modified by Thorarin Bjarnason to work with AnalyzeNNLS
% 2008.05.26
%
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>: 
%{
    clear;
    %Inital values
    handles.MultiechoPath = '';
    handles.MultiechoName = 'ag11838_003.bff.gz';
    %
    %Load Data
    handles = qT2_readbff('0',handles);
    %

%}
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


%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end

%
%  Set default file type.
%
if( nargin == 1 )
	type = 'uint16';
end

%Set filename
filename = [h.MultiechoPath,h.MultiechoName];
%

%
%  If it is a compressed file, then uncompress it...
%
pos = findstr(filename, '.gz');

if( ~isempty( pos ) && ( pos == length(filename)-2 ) )
	compressed_flag = 1;
	old_filename = filename;
	filename = filename(1:end-3);
%	unix(sprintf('gunzip -c %s > %s', old_filename, filename));
    gunzip( old_filename )
else 
	compressed_flag = 0;
end

endian = 'little'; % default
nimages = 0;
nchannels = 0;

%
%  Open the file.
%
fp = fopen(filename);

ii=1;

while( 1 )

	line = fgetl(fp);

    if( length(line) >= 1 && line(1) == 12 )
		break;
    end

    if( length(line) > 6 && strcmp(line(1:6), 'nrows:') == 1 )
		nrows = str2double(line(7:end));
    end

    if( length(line) > 6 && strcmp(line(1:6), 'ncols:') == 1 )
		ncols = str2double(line(7:end));
    end

    if( length(line) > 8 && strcmp(line(1:8), 'nslices:') == 1 )
		nslices = str2double(line(9:end));
    end

    if( length(line) > 8 && strcmp(line(1:8), 'nimages:') == 1 )
		nimages = str2double(line(9:end));
    end

    if( length(line) > 8 && strcmp(line(1:8), 'nechoes:') == 1 )
		nechoes = str2double(line(9:end));
    end

    if( length(line) > 10 && strcmp(line(1:10), 'nchannels:') == 1 )
		nchannels = str2double(line(11:end));
    end

    if( length(line) > 7 && strcmp(line(1:7), 'endian:') == 1 )
		endian = line(8:end);
    end

    if( length(line) > 5 && strcmp(line(1:5), 'type:') == 1 )
		type = line(6:end);
    end
    
%     if( length(line) > 4 && strcmp(line(1:4), 'fov:') == 1 )
% 		fov = str2double(line(5:end));
%     end
    
    if( length(line) > 9 && strcmp(line(1:9), 'pixwidth:') == 1 )
		pixwidth = str2double(line(10:end));
    end
    
    if( length(line) > 10 && strcmp(line(1:10), 'pixheight:') == 1 )
		pixheight = str2double(line(11:end));
    end
    
    if( length(line) > 9 && strcmp(line(1:9), 'pixthick:') == 1 )
		pixthick = str2double(line(10:end));
    end
    
    if( length(line) > 3 && strcmp(line(1:3), 'te:') == 1 )
		te = str2num(line(4:end)); %#ok<ST2NM>
    end
	
	ii = ii + 1;
end

%
%  Strip off the white space from "type"
%

if( type == ' ' )
	type = 'double';
else
	aa = find( (type==' ') == 0);
	bb = length(type)-find( (fliplr(type)==' ') == 0)+1;
	type = type(aa:bb);
end

if( ~isempty( findstr( endian, 'big') ) )
	disp('readbff: Re-opening file in big endian mode');
	%
	%  Open file in big endian mode.
	%
	fp = fopen(filename, 'rb', 'b');
	while( 1 )
		line = fgetl(fp);
		if( length(line) >= 1 && line(1) == 12 )
			break;
		end
	end
end

if( nchannels == 0 )
	warning('Old style BFF, nchannels not defined, using nechoes'); %#ok<WNTAG>
	nchannels = nechoes;
end

%set endian
if findstr(endian,'big')
    endian = 'b';
elseif findstr(endian, 'little')
    endian = 'l';
end

%read data
if( nslices*nchannels < nimages ) 
	data = fread(fp, nrows*ncols*nimages, type, endian);
else 
	data = fread(fp, nrows*ncols*nslices*nchannels, type, endian);
end

fclose(fp);

if( nslices*nchannels < nimages )
	data = squeeze(reshape( data, [ncols nrows nimages]));
else
	data = squeeze(reshape( data, [ncols nrows nchannels nslices]));
end

if (ndims(data) <= 3)  
  data = permute(data,[2,1,3:ndims(data)]); 
else
  data = permute(data,[2,1,4,3,5:ndims(data)]);
end  

%
%  Delete the temporary file.
%
if( compressed_flag ) 
	delete(filename);  
end


if hObject == '0'
    %non-gui case
    %Assign to handles
    h.MultiEcho.dim = length(size(data));
    h.MultiEcho.size = size(data);
    h.MultiEcho.FOV = [pixheight*h.MultiEcho.size(1)/10 ...
        pixwidth*h.MultiEcho.size(2)/10 pixthick];
    h.MultiEcho.data = data;
    h.MultiEcho.te = te;
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(data);
else
    %gui case
    %load file
    %Assign to handles
    h.MultiEcho.dim = length(size(data));
    h.MultiEcho.size = size(data);
    h.MultiEcho.FOV = [pixheight*h.MultiEcho.size(1)/10 ...
        pixwidth*h.MultiEcho.size(2)/10 pixthick];
    h.MultiEcho.data = data;
    h.MultiEcho.te = te;
    %is data real or complex? 1 for real, 0 for complex
    h.MultiEcho.DataType = isreal(data);
    %Update handles
    guidata(hObject,h);
    %
end

