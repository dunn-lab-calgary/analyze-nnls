%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% Began by Craig Jones
% Last modified 2008.05.26
%
% qT2_readrec.m
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  This will read in a rec file from the Philips scanner.
%  It will read in REC files even with real and imaginary data
%  as well as do the appropriate signal intensity adjustments
%  as the REC file stores uint16, but the underlying data can be 
%  positive or negative.
%
% Craig Jones (craig@mri.jhu.edu)  April 28, 2004
% 20080411 TB - for multislice data, I am assuming all slices have the same
%                echo times.
% 20070316 TB - Incorporated to aNNLS, reading complex data
% 20050120 TB - Reading Echos instead of dynamics now
% 20040510 CJ - changed reading loop to be over size(A,1)
% 20040527 CJ - checked for 'rec' and 'REC'  
% 20040624 CJ - fixed TeX interpreter, 
%
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:  
%{
    clear;
    %Inital values
    handles.MultiechoPath = '';
    handles.MultiechoName = '3D_32_10_GRASE_CLEAR_6_3.REC';
    %
    %Load Data
    [handles] = qT2_readrec('0',handles);
    %
    figure(1);
    subplot(2,2,1);
    imagesc( abs( handles.MultiEcho.data(:,:,1) ) ); colormap(gray); colorbar;
    title('Magnitude')
    subplot(2,2,2);
    imagesc( real( handles.MultiEcho.data(:,:,1) ) ); colormap(gray); colorbar;
    title('Real')
    subplot(2,2,3);
    imagesc( imag( handles.MultiEcho.data(:,:,1) ) ); colormap(gray); colorbar;
    title('Imaginary')
    subplot(2,2,4);
    imagesc( angle( handles.MultiEcho.data(:,:,1) ) ); colormap(gray); colorbar;
    title('phase')
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
%need: FOV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%function [v, v_real, v_imag] = qT2_readrec(filename)
function h = qT2_readrec(hObject,h)

%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end

filename = [h.MultiechoPath,h.MultiechoName];

%=================================================================
%
%  Load in the PAR file and do the necessary conversions.
%
%=================================================================
if( strcmp(filename(end-2:end), 'rec') )
	filename_par = strrep(filename, 'rec', 'par');
else
	filename_par = strrep(filename, 'REC', 'PAR');
end

[nrows, ncols, nslices, ndynamics, nechos, A, ...
        fov, pixwidth, pixheight, pixthick, te, echoFlag] = ...
    qT2_parseParHeader(filename_par);
%Assign to headers

fprintf('Reading in %s:  %dx%d %d slices and %d echos\n', ...
	filename, nrows, ncols, nslices, nechos);

%=================================================================
%
%  Number of types of scans:  0=magnitude, 1 = Real, 2 = Imaginary
%
%=================================================================
ntypes = length( unique(A(:,5)) );
v = zeros([nrows ncols nslices nechos ntypes]);

%=================================================================
%  
%  Read in the data.
% 
%=================================================================
if( findstr(filename, '.gz') )
	tmpname = tempname;
	unix(sprintf('gzcat %s > %s', filename, tmpname));
else 
	tmpname = filename;
end

fp = fopen(tmpname, 'rb', 'l');

hbar = waitbar(0,''); set(findall(hbar,'type','text'),...
    'Interpreter','none', 'string', sprintf('Loading REC file'));
for ii=1:size(A,1)
    %calculated according to equation in header of PAR file
    %NOTE: the first part of the data is a T2map. It is indexed
    % as 1 1 1, as is the next bunch of data, which is the start
    % of the actual collected data. So, the data will write over the
    % T2map because it has the same index. If there is no T2map, the
    % index will still be 1 1 1, and all is well.
      % 2005.10.26Joseph - I have changed the 5th dimension of the v matrix
      % from A(ii,3) to A(ii,5)+1 as this last dimension is suppose to map
      % the data according to their types (0=magnitude, 1=real,
      % 2=imaginary). The original one is wrong as it is reading the wrong
      % column from the PAR file's table and the +1 is used for the
      % positioning as v(0) doesn't exist
      %
      % Using FP = (PV * RS + RI )/( RS*SS ) from par header, V4
      %
      if echoFlag == 'e' %use echoes stored as echoes
          v(:,:,A(ii,1),A(ii,2),(A(ii,5)+1)) = ...
              ( (fread(fp, [nrows, ncols], 'int16'))*A(ii,13) + ...
              A(ii,12 ) )/( A(ii,13) * A(ii,14) );
      elseif echoFlag == 'c' %use echoes stored as cardiac phases
          v(:,:,A(ii,1),A(ii,4),(A(ii,5)+1)) = ...
              ( (fread(fp, [nrows, ncols], 'int16'))*A(ii,13) + ...
              A(ii,12 ) )/( A(ii,13) * A(ii,14) );
      else
          disp('Something went wrong with where the echoes are stored')
      end
        %2005.02.25THOR = I took the scaling out for the T2 data because it
        %  is not needed. There is a phillips error when doing phantom work
        %  (ie different coil loading than a head) in that the scaling
        %  factor made the data > 2^16.
%	v(:,:,A(ii,1),A(ii,2),A(ii,3)) = ...
%			(fread(fp, [nrows, ncols], 'intMACKAY_SK_COMPARISON_V01_4_116')* A(ii,9) + ...
%            A(ii,8))/(A(ii,9)*A(ii,10));
%	v(:,:,A(ii,1),A(ii,2),A(ii,3)) = ...
%			fread(fp, [nrows, ncols], 'int16')* A(ii,9) + A(ii,8);
%   	v(:,:,A(ii,1),A(ii,2),A(ii,5)+1) = ...
%			fread(fp, [nrows, ncols], 'int16')* A(ii,9) + A(ii,8);
	
    
    waitbar(ii/length(A),hbar)
end
close(hbar);

fclose(fp);

if( findstr(filename, '.gz') )
	delete(tmpname);
end

%%reorder data
v = permute(v,[2,1,4,3,5]);
%%A

%try to find a way to just take the corresponding data
%Joseph - this following one lets the v matrix returns only the magnitude
%images. If the interested images are the real(2) or the imaginary(3) ones,
%just change the 1 to 2 or 3, respectively

if length(size(v)) > 4 %complex data
    v_real = v(:,:,:,:,2);
    v_imag = v(:,:,:,:,3);
    h.MultiEcho.data = v_real + i*v_imag;
    %1 for real, 0 for complex
    h.MultiEcho.DataType = 0;
    h.MultiEcho.dim = 3; 
    h.MultiEcho.size = [nrows, ncols, nechos nslices];
    te = sort(te); %sort to make sure same echoes sit side by side
    h.MultiEcho.te = te(1:nslices:end)'*1000;
    h.MultiEcho.FOV = fov;
else
%    v = permute(v,[1,2,4,3]);
    h.MultiEcho.data = v;
    h.MultiEcho.DataType = 1;
    h.MultiEcho.dim = 4;
    %h.MultiEcho.size = [nrows, ncols, nslices, nechos];
    h.MultiEcho.size = [nrows, ncols, nechos, nslices];
    te = sort(te); %sort to make sure same echoes sit side by side
    h.MultiEcho.te = te(1:nslices:end)'*1000; %assuming each slice has the same te.
    h.MultiEcho.FOV = fov;
end

% when the number of echoes is stored as cardiac phases, te is not
% reliable, because it is only 1 value throughout. I will assume this value
% is correct and that the echo spacing is even throughout. 2009.07.14
if echoFlag == 'c'
    h.MultiEcho.te = ...
        (h.MultiEcho.te(1):h.MultiEcho.te(1):h.MultiEcho.te(1)*nechos);
end
%


if hObject ~= '0'
    %gui case
    %Update handles
    guidata(hObject,h);
    %
end

