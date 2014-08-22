%========================================================================
function [nrows, ncols, nslices, ndynamics, nechos, A, ...
        fov, pixwidth, pixheight, pixthick, te, echoFlag] = ...
    qT2_parseParHeader(filename_par)
%function [nrows, ncols, nslices, ndynamics, nechos, A] = ...
%    parseParHeader(filename_par)

%  parseHeader - Parse a Philips PAR file for some important 
%  parameters
%

%  Craig Jones (craig@mri.jhu.edu)  
%   further modified by Thor Bjarnason
%  20070316 - Modified by Thor to be interfaces with AnalyzeNNLS

nrows = 0; ncols = 0; nslices = 0; ndynamics = 0; nechos = 0; %#ok<NASGU>
echoFlag = ''; %used in case the echoes are stored with the cardiac phases.

line = ''; %#ok<NASGU>
fp = fopen(filename_par, 'rt');

%line = fgetl(fp);
while( 1 )
    line = fgetl(fp);

    if findstr('sl ec', line) > 0, break, end;
        
    if ( strncmp('#sl', line, 3) == 1), break, end;
    %{
    %%  Look for number of rows and columns
    if( findstr('Recon resolution', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2num(aa);
        nrows = aa(1);  ncols = aa(2);  %nrows = x
    end
    %}
    %% Look for fov
    if(findstr('FOV', line) >0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2num(aa); %#ok<ST2NM>
        fovx = aa(1)/10; fovz = aa(2)/10; fovy = aa(3)/10;
        fov = [fovy fovx fovz];
    end

    %%  Look for number of slices
    if( findstr('number of slices', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2double(aa);
        nslices = aa(1);
    end

    %%  Look for number of dynamics
    if( findstr('number of dynamics', line) > 0 )
        aa = line(findstr(':', line)+1:end);
        aa = str2double(aa);
        ndynamics = aa(1);
    end
    
    %%  Look for number of echos
    if nechos == 0 || nechos == 1
        if( findstr('number of echoes', line) > 0 )
            aa = line(findstr(':', line)+1:end);
            aa = str2double(aa);
            nechos = aa(1);
            echoFlag = 'e'; %echoes are stored as 'echoes'
        end
    end
    %%  Sometimes this shows up in cardiac phases. At least Boogies 10
    %%  slice 48 echo data does this (2009.07.14)
    if nechos == 0 || nechos == 1
        if( findstr('number of cardiac phases', line) > 0 )
            aa = line(findstr(':', line)+1:end);
            aa = str2double(aa);
            nechos = aa(1);
            echoFlag = 'c'; %echoes are stored as 'cardiac phases'
        end
    end
end


line = fgetl(fp); %#ok<NASGU>

ii = 1; 
while( 1 )

    line = fgetl(fp);
    if( length(line) < 2 ), break; end
    
    A(ii,:) = str2num(line);   %#ok<AGROW,ST2NM> %could be streamlined so A does not grow inide a loop
    ii = ii + 1;
end
nrows = A(1,10);  ncols = A(1,11);
fclose(fp);

%Calculate additional parameters needed by our analysis software
pixthick = fovz;
pixheight = fovx/nrows;
pixwidth = fovy/ncols;
te = A(:,31)/1000;
te = te(1:end);  %This correction is needed because our GE data
                 % had 'te starting at 10ms, here it is 0ms