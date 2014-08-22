function [ img, Header ] = qT2_Varian_fdf(pathname, filename)
% m-file that can open Varian FDF imaging files in Matlab.
%
% Modified by Thorarin Bjarnason with ImagingInformatics.ca for use with
% AnalyzeNNLS. First edit 2008.11.27, last edit 2008.11.28. The file was
% originally named fdf.m
%
% Usage: img = fdf(filename,path);
% Your image data will be loaded into img
%
% Shanrong Zhang
% Department of Radiology
% University of Washington
% 
% email: zhangs@u.washington.edu
% Date: 12/19/2004
% 
% Fix Issue so it is able to open both old Unix-based and new Linux-based FDF
% Date: 11/22/2007
%

warning off MATLAB:divideByZero;

[fid] = fopen([pathname filename],'r');

num = 0;
done = false;
machineformat = 'ieee-be'; % Old Unix-based  
line = fgetl(fid);

while (~isempty(line) && ~done)
    line = fgetl(fid);
    %disp(line)
    if strmatch('int    bigendian', line)
        machineformat = 'ieee-le'; % New Linux-based    
    end
    
    if strmatch('float  matrix[] = ', line)
        [token, rem] = strtok(line,'float  matrix[] = { , };');
        M(1) = str2double(token);
        M(2) = str2double(strtok(rem,', };'));
    end
    if strmatch('float  bits = ', line)
        [token, rem] = strtok(line,'float  bits = { , };'); %#ok<NASGU>
        bits = str2double(token);
    end

    num = num + 1;
    Header{num} = line; %#ok<AGROW>
    
    if num > 41
        done = true;
    end
end

skip = fseek(fid, -M(1)*M(2)*bits/8, 'eof'); %#ok<NASGU>

img = fread(fid, [M(1), M(2)], 'float32', machineformat);

img = img';


% end of m-code
