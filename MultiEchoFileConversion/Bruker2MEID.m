%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thorarin Bjarnason
% 2007.06.18 Last modified 2010.01.28
%
% Bruker2MEID.m
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assumptions:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Header information and fid are in the same dir
% - header information is in the 'acqp' file and fid is 'fid' file
% - assuming unix or linux, so folders use '/'
% - single slice for now. Need to incorporate nslices into KImage stuff
% - ncols and nrows might need to be switched around
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
directory = '../201001Mecit/Cheese1.0m1/35/';

%Phase encode flag, 1 or 0
PEflag = 1;
%
flipEvenEchoes = 0; %for Poon-Henkelman CPMG, we need to flip every 
                   %even echo (0,1,2,etc) . 1 if true.
%
AdjacentSlices = 0; %1 for sequential <adjacent> slices, 0 for 
                    %non-adjacent, assuming the following silce order for 5
                    %slice data: 1,3,5,2,4. This is the case for 7-T data
                    %from Mecit <use 0>


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


line = ''; %#ok<NASGU>
%determine MEID filename from dir structure
s = strfind( directory, '/' ); %NOTE, needs to be different for windows
MEID.filename = directory( s(end-2) + 1 : s(end-1) -1 );
MEID.filename = [MEID.filename, '.mat'];
%

%start parsing header
%open file
fp = fopen( [ directory, 'acqp' ], 'r' );
%read data until end of file is reached
line = fgetl(fp);
while ~strcmp( '##END=', line )
    
    %acquired
    if( findstr( '##$ACQ_time', line ) )
        line = fgetl(fp);
        MEID.acquired = line;
    end
    
    %byte order
    if( findstr( '##$BYTORDA', line ) )
        aa = line( findstr( '=', line)+1 : end );
        if findstr( 'little', line )
            MEID.byte_order = 'l';  
        elseif findstr( 'big', line )
            MEID.byte_order = 'b';
        end
    end
    
    %echo_times
    if( findstr( '##$ACQ_echo_time', line ) )
        aa = line( findstr( '=', line )+2 : end-1 );
        nmax = str2num( aa ); %#ok<ST2NM>
        n = 0;
        aa = '';
        while n < nmax
            line = fgetl(fp);
            aa = [ aa, line ]; %#ok<AGROW>
            n = length( str2num( aa ) ); %#ok<ST2NM>
        end
        aa = str2num( aa ); %#ok<ST2NM>
        MEID.echo_times = aa;
    end
    
    %fov
    if( findstr( '##$ACQ_fov', line ) )
        line = fgetl(fp);
        aa = str2num( line ); %#ok<ST2NM> %assuming fov is in cm
        MEID.FOV = aa;
    end
    
    %naverages
    if( findstr( '##$NA=', line ) )
        aa = line( findstr( '=', line )+1 : end );
        aa = str2num(aa); %#ok<ST2NM>
        MEID.naverages = aa;
    end
    
    %ncolumns and nrows
    if( findstr( '##$ACQ_size', line ) )
        line = fgetl(fp);
        aa = str2num( line ); %#ok<ST2NM>
        MEID.nrows = aa(1)/2; %not sure why I need to divide by 2
        MEID.ncols = aa(2); %Might need to switch these. I won't know until
                            %I see more data
    end
    
    %nechoes
    if( findstr( '##$NECHOES', line ) )
        aa = line( findstr( '=', line )+1 : end );
        aa = str2num( aa ); %#ok<ST2NM>
        MEID.nechoes = aa;
    end
    
    %nslices
    if( findstr( '##$NSLICES', line ) )
        aa = line( findstr( '=', line)+1 : end );
        aa = str2num( aa ); %#ok<ST2NM>
        MEID.nslices = aa; 
    end
    
    %poon-henkelman CPMG?
    if( findstr( '<CPMG_Imag.ppg>', line ) )
        flipEvenEchoes = 1;
    end
    %
    
    %slice thickness
    if( findstr( '##$ACQ_slice_thick', line ) )
        aa = line( findstr( '=', line)+1:end);
        aa = str2num(aa); %#ok<ST2NM> %assuming slice thickness in cm
        MEID.slice_thickness = aa;
    end
    
    %TR
    if( findstr( '##$ACQ_repetition_time', line ) )
        line = fgetl(fp);
        aa = str2num(line); %#ok<ST2NM> %assuming ms
        MEID.TR = aa;
    end
    
    line = fgetl(fp);
end
%
%close file
fclose( fp );
%end parsing header



%%%%%End Header Information%%%%%%


%%%%%Read in data%%%%%%
fid = fopen([directory, 'fid'],'r', MEID.byte_order );
KImage = fread(fid,'long');
if MEID.nslices == 1
    KImage = reshape(KImage, [ 2 MEID.nrows MEID.nechoes MEID.ncols ]);
    % I might need to switch rows and cols once I see more data
    KImage = KImage(1,:,:,:) + i*KImage(2,:,:,:);
    KImage = reshape(KImage, [MEID.nrows MEID.nechoes MEID.ncols]);
    if PEflag == 1
        KImage = flipdim( permute(KImage, [3 1 2]) , 1) ;
    else
        KImage = flipdim( flipdim( permute(KImage, [1 3 2]), 1), 2);
    end
    fclose(fid);
    %

%    %shift data to centre k-space
%    KImage(:,:,:) = circshift( KImage(:,:,:), [ 1 -14 0 ] );
%    %


    figure(1);
    imagesc( abs( log( KImage(:,:,1) - min(min(KImage(:,:,1))) +1  ) ) ); 
    colormap(gray); colorbar;


    %FFT to image space
    for i = 1:length( KImage(1,1,:) )
        tmp = fftshift( KImage(:,:,i) );
        %flip every even echo if pulse sequence is the poon-henkelman
        %cpmg (echo 0, 2, 4, )
        if flipEvenEchoes == 1
            if ~mod(i+1,2)
                if PEflag == 1
                    tmp = flipud( tmp );
                else
                    tmp = fliplr( tmp ); 
                end
            end
            tmp = fliplr( tmp ); %in order to display the same as the
                                    %Bruker console. 2009.06.17
        end
        MEID.DATA(:,:,i) = fftshift( fft2( tmp ) );
        % Below can be ued to circular shift the image to centre it. 
        % [ up/down, left/right, 0]
%        MEID.DATA(:,:,i) = circshift( MEID.DATA(:,:,i), [ 0 12 0 ] );
    end
    %

    figure(2);
    imagesc( angle( MEID.DATA(:,:,1) ) ); colormap(gray); colorbar;

    figure(3);
    polar( angle( MEID.DATA(:,:,1) ), abs( MEID.DATA(:,:,1) ), 'b.' );
else   %This condition could be more elegantly integrated with the one above, I think.
    KImage = reshape(KImage, ...
        [ 2 MEID.nrows MEID.nechoes MEID.nslices MEID.ncols ]);
    % I might need to switch rows and cols once I see more data
    KImage = KImage(1,:,:,:,:) + i*KImage(2,:,:,:,:);
    KImage = reshape(KImage, ...
        [MEID.nrows MEID.nechoes MEID.nslices MEID.ncols]);
    KImage = flipdim( permute(KImage, [4 1 2 3]) , 1) ;
    fclose(fid);
    %

%    %shift data to centre k-space
%    KImage(:,:,:) = circshift( KImage(:,:,:), [ 1 -14 0 ] );
%   %



    figure(1);
    imagesc( abs( log( KImage(:,:,1,1) - min(min(KImage(:,:,1,1))) +1  ) ) ); 
    colormap(gray); colorbar;


    %FFT to image space
    for i = 1:length( KImage(1,1,:,1) ) %echoes
        for j = 1:length( KImage(1,1,1,:) ) %slices
            %flip every second echo if pulse sequence is the poon-henkelman
            %cpmg
            if flipEvenEchoes == 1
                if ~mod(i,2)
                    tmp = flipud( tmp ); %#ok<NASGU>
                end
            end
            tmp = fftshift( KImage(:,:,i,j) );
            MEID.DATA(:,:,i,j) = fftshift( fft2( tmp ) );
        end
    end
    %
    
    figure(2);
    imagesc( abs( MEID.DATA(:,:,1,1) ) ); colormap(gray); colorbar;

%Below used to see if I centred K-space correctly
%    figure(2);
%    imagesc( angle( MEID.DATA(:,:,1) ) ); colormap(gray); colorbar;

%    figure(3);
%    polar( angle( MEID.DATA(:,:,1) ), abs( MEID.DATA(:,:,1) ), 'b.' );


end
%%%%%End Read in data%%%%%%

%Reorder slices if needed
tmp = zeros( size( MEID.DATA) );
j = 1;
if AdjacentSlices == 0  %if this flag is set to zero, 
                        %non-adjacent slice aquisition assumed
    for i = 1:2:MEID.nslices
        tmp(:,:,:,i) = MEID.DATA(:,:,:,j);
        j = j+1;
    end
    for i = 2:2:MEID.nslices
        tmp(:,:,:,i) = MEID.DATA(:,:,:,j);
        j = j+1;
    end
end
MEID.DATA = tmp;
clear tmp
%



%%%%%Write out Data%%%%%%%

%Create new folder
s = strfind( directory, '/' ); %NOTE, needs to be different for windows
MEID.directory = directory(1:s(end-2));
%
% 
%Save matlab format data
save( [MEID.directory, MEID.filename ], 'MEID' );
movefile( [ MEID.directory, MEID.filename], ...
    [ MEID.directory, MEID.filename(1:end-4), '.MEID' ] );
%


%Create figures to save, will overwrite inforation above and can be deleted
%in the future
figure(1); 
imagesc( abs( MEID.DATA(:,:,1) ) ); colormap(gray); colorbar;
figure(2); 
imagesc( abs( MEID.DATA(:,:,end) ) ); colormap(gray); colorbar;
figure(3);
imagesc( abs( log( KImage(:,:,1) - min(min(KImage(:,:,1))) +1  ) ) );
colormap(gray); colorbar;
figure(4);
imagesc( abs( log( KImage(:,:,end) - min(min(KImage(:,:,end))) +1  ) ) );
colormap(gray); colorbar;
%%%%%End Write out Data%%%%%%%


