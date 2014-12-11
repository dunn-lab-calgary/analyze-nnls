% Program to produce 3D matlab image data sets from signa P files
% by: W. Oakden
% Modified by: Thorarin Bjarnason for use with AnalyzeNNLS.
%   began: 2007.01.17    last edited 2008.05.26
%   code can still be streamlined

% - This function loads qT2 GE p-files
% - NOTE: users need to know the length of the header.
% - Sample Call <copy and paste somewhere else, making sure this function
%       is in the PATH>:   NOT DONE
%{
    clear;
    %Inital values
    handles.MultiechoPath = [''];
    handles.MultiechoName = 'P13312.7';
    %
    %Load Data
    [handles] = qT2_LoadPfiles('0',handles);
    %

%}
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
%

% NOTE: PHASED ARRAY COILS
function h = qT2_LoadPfiles(hObject,h)

%Clear MultiEcho field if previously used
if isfield( h, 'MultiEcho' )
    h = rmfield(h,'MultiEcho');
end


%warning off
filename = [h.MultiechoPath,h.MultiechoName];
ms1 = 128;
ms2 = 128;
echos = 32;
coils = 1;
zerofill = 'n';

 

%header = 66072;  % header size for LX
header = 61464; %old one


if zerofill == 'n',
  mag_data=zeros(ms1,ms2,echos);
  phase=zeros(ms1,ms2,echos);
else
  mag_data=zeros(256,256,echos);
  phase=zeros(256,256,echos);
end;

Re_mat=zeros(ms1,ms2,echos);
Im_mat=zeros(ms1,ms2,echos);

%fermi = FermiFilter(ms1, 0.9, 3.5);

fid = fopen(filename,'r');
fseek(fid,header,'bof');

pointer = header+ms1*2*2;

for coil=1:coils

    for echo=1:echos,

    %  disp(['Echo #: ' num2str(echo)]);
    %  disp('Reading data/Creating image');
      % ### Skip to beginning of image data, past baseline view
      fseek(fid,pointer,'bof');
      % real and imaginary pairs
      R= fread(fid,[ms1,ms2],'short',2, 'l');
      fseek(fid,pointer+2,'bof');
      I= fread(fid,[ms1,ms2],'short',2, 'l');

      Re_mat(:,:,echo)=R;
      Im_mat(:,:,echo)=I;

      % The ifft2 function will zero fill to 256x256

      if zerofill == 'y',
         M = fftshift(ifft2((R+I*i),256,256));  
      else 
    %    M = fftshift(ifft2(fftshift((R+I*i).*fermi),ms1,ms2));
        M = fftshift(ifft2(fftshift((R+I*i)),ms1,ms2));
      end

    % mag_data(:,:,echo) = abs(R+I*i); 
       h.MultiEcho.data(:,:,echo) = M/coils*1000;
       mag_data(:,:,echo)=mag_data(:, :, echo) + (abs(M)/coils);
       phase(:,:,echo)= atan(imag(M)./real(M));
       pointer=pointer + (ms1*2*2+ms1*ms2*2*2);
    end
end

%is data real or complex? 1 for real, 0 for complex
h.MultiEcho.DataType = isreal(h.MultiEcho.data);
h.MultiEcho.dim = 3; 
h.MultiEcho.size = [ms1, ms2, echos];
h.MultiEcho.te = 10:10:echos*10;
h.MultiEcho.FOV(1:h.MultiEcho.dim) = 0; %not given
%

if hObject ~= '0'
    %gui case
    %Update handles
    guidata(hObject,h);
    %
end
