function Data = blkGetData(fnBLK,BLKHeader,iFrames)

%% Get the data from a BLK imaging file
% Return a 3-D array: Y,X,T
% fnBLK is the BLK filename incliding pathname.
%
%
% YC at ES lab
% Created on Apr. 14, 2008
% Last modified on Apr. 14, 2008

%% Read header and set data type
if ~exist('BLKHeader','var')
  BLKHeader = blkGetHeader(fnBLK);
end

switch BLKHeader.DataType
  case BLKHeader.DEF.DataType.DAT_UCHAR
    DataType = 'uchar';
    nDataType = 1;
  case BLKHeader.DEF.DataType.DAT_USHORT
    DataType = 'ushort';
    nDataType = 2;
  case BLKHeader.DEF.DataType.DAT_LONG
    DataType = 'long';
    nDataType = 4;
  case BLKHeader.DEF.DataType.DAT_FLOAT
    DataType = 'float';
    nDataType = 4;
end

%% Open file
fid = fopen(fnBLK,'r','l');
if fid==-1
	error(['Invalid filename: ',fnBLK]);
end

%% Read data
fseek(fid,BLKHeader.StimOffs,'bof');  % go to data offset
Data = ...
  permute(reshape(fread(fid,BLKHeader.StimSize/nDataType,DataType), ...
                  [BLKHeader.FrameWidth,BLKHeader.FrameHeight, ...
                   BLKHeader.NFramesPerStim]),[2,1,3]);

%% Return data
if exist('iFrames','var')
  Data = Data(:,:,iFrames);
end

%% Close file
fclose(fid);


