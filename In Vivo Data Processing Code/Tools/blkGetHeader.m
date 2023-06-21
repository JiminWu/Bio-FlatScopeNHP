function BLKHeader = blkGetHeader(fnBLK)

%% Get the header from a BLK imaging file
% Appendix A in VDaqTasks3001.pdf
% fnBLK is the BLK filename incliding pathname.
%
%
% YC at ES lab
% Created on Apr. 13, 2008
% Last modified on Apr. 14, 2008

%% Open file
fid = fopen(fnBLK,'r','l');
if fid==-1
	error(['Invalid filename: ',fnBLK]);
end

%% Definitions
BLKHeader.DEF.FileType.RAWBLOCK_FILE = 11;
BLKHeader.DEF.FileType.DCBLOCK_FILE  = 12;
BLKHeader.DEF.FileType.SUM_FILE      = 13;
BLKHeader.DEF.FileType.IMAGE_FILE    = 14;

BLKHeader.DEF.FileSubType.FROM_VDAQ = 11;
BLKHeader.DEF.FileSubType.FROM_ORA  = 12;

BLKHeader.DEF.DataType.DAT_UCHAR  = 11;
BLKHeader.DEF.DataType.DAT_USHORT = 12;
BLKHeader.DEF.DataType.DAT_LONG   = 13;
BLKHeader.DEF.DataType.DAT_FLOAT  = 14;

%% Read header

% Data integrity
BLKHeader.FileSize        = fread(fid,1,'long');
BLKHeader.CheckSum_Header = fread(fid,1,'long');  % beginning with the lLen Header field
BLKHeader.CheckSum_Data   = fread(fid,1,'long');

% Common to all data files
BLKHeader.LenHeader = fread(fid,1,'long');
BLKHeader.VersionID = fread(fid,1,'long');
BLKHeader.FileType = fread(fid,1,'long');  % e.g. DCBLOCK_FILE, RAWBLOCK_FILE
BLKHeader.FileSubtype = fread(fid,1,'long');  % e.g. FROM_VDAQ, FROM_ORA
BLKHeader.DataType = fread(fid,1,'long');  % e.g. DAT_UCHAR, DAT_USHORT
BLKHeader.SizeOf = fread(fid,1,'long');  % e.g. sizeof(long), sizeof(float)
BLKHeader.FrameWidth = fread(fid,1,'long');
BLKHeader.FrameHeight = fread(fid,1,'long');
BLKHeader.NFramesPerStim = fread(fid,1,'long');  % data frames
BLKHeader.NStimuli = fread(fid,1,'long');
BLKHeader.InitialXBinFactor = fread(fid,1,'long');  % from data acquisition
BLKHeader.InitialYBinFactor = fread(fid,1,'long');  % from data acquisition
BLKHeader.XBinFactor = fread(fid,1,'long');  % this file
BLKHeader.YBinFactor = fread(fid,1,'long');  % this file
BLKHeader.UserName = fread(fid,32,'*char')';
BLKHeader.RecordingDate = fread(fid,16,'*char')';
BLKHeader.X1ROI = fread(fid,1,'long');
BLKHeader.Y1ROI = fread(fid,1,'long');
BLKHeader.X2ROI = fread(fid,1,'long');
BLKHeader.Y2ROI = fread(fid,1,'long');

% Locate data and ref frames
BLKHeader.StimOffs = fread(fid,1,'long');
BLKHeader.StimSize = fread(fid,1,'long');
BLKHeader.FrameOffs = fread(fid,1,'long');
BLKHeader.FrameSize = fread(fid,1,'long');
BLKHeader.RefOffs = fread(fid,1,'long');  % Imager 3001 has no ref
BLKHeader.RefSize = fread(fid,1,'long');  % these fields will be 0
BLKHeader.RefWidth = fread(fid,1,'long');
BLKHeader.RefHeight = fread(fid,1,'long');

% Common to data files that have undergone some form of "compression"
%    or "summing"; i.e. The data in the current file may be the
%    result of having summed blocks 'a'-'f', frames 1-7
BLKHeader.WhichBlocks = fread(fid,16,'ushort');  % 256 bits => max of 256 blocks per expt
BLKHeader.WhichFrames = fread(fid,16,'ushort');  % 256 bits => max of 256 frames per condition

% Data analysis
BLKHeader.LoClip = fread(fid,1,'float');
BLKHeader.HiClip = fread(fid,1,'float');
BLKHeader.LoPass = fread(fid,1,'long');
BLKHeader.HiPass = fread(fid,1,'long');
BLKHeader.OperationsPerformed = fread(fid,64,'*char')';

% Ora-specific—not needed by Vdaq
BLKHeader.Magnification = fread(fid,1,'float');
BLKHeader.Gain = fread(fid,1,'ushort');
BLKHeader.Wavelength = fread(fid,1,'ushort');
BLKHeader.ExposureTime = fread(fid,1,'long');
BLKHeader.NRepetitions = fread(fid,1,'long');  % # of repetitions
BLKHeader.AcquisitionDelay = fread(fid,1,'long');  % delay of DAQ relative to Stim-Go
BLKHeader.InterStimInterval = fread(fid,1,'long');  % time interval between Stim-Go's
BLKHeader.CreationDate = fread(fid,16,'*char')';
BLKHeader.DataFilename = fread(fid,64,'*char')';
BLKHeader.OraReserved = fread(fid,256,'*char')';

% Vdaq-specific
BLKHeader.IncludesRefFrame = fread(fid,1,'long');  % 0 or 1
BLKHeader.ListOfStimuli = fread(fid,256,'*char')';
BLKHeader.NFramesPerDataFrame = fread(fid,1,'long');
BLKHeader.NTrials = fread(fid,1,'long');
BLKHeader.ScaleFactor = fread(fid,1,'long');  % NFramesAvgd * Bin * Trials
BLKHeader.MeanAmpGain = fread(fid,1,'float');
BLKHeader.MeanAmpDC = fread(fid,1,'float');
BLKHeader.BegBaselineFrameNo = fread(fid,1,'uchar');  % SUM-FR/DC File (i.e. compressed)
BLKHeader.EndBaselineFrameNo = fread(fid,1,'uchar');  % SUM-FR/DC File (i.e. compressed)
BLKHeader.BegActivityFrameNo = fread(fid,1,'uchar');  % SUM-FR/DC File (i.e. compressed)
BLKHeader.EndActivityFrameNo = fread(fid,1,'uchar');  % SUM-FR/DC File (i.e. compressed)
BLKHeader.DigitizerBits = fread(fid,1,'uchar');  % cam_GetGrabberBits
BLKHeader.ActiveSystemID = fread(fid,1,'uchar');  % core_ActiveSystemID()
BLKHeader.Dummy2 = fread(fid,1,'uchar');
BLKHeader.Dummy3 = fread(fid,1,'uchar');
BLKHeader.X1SuperPix = fread(fid,1,'long');
BLKHeader.Y1SuperPix = fread(fid,1,'long');
BLKHeader.X2SuperPix = fread(fid,1,'long');
BLKHeader.Y2SuperPix = fread(fid,1,'long');
BLKHeader.FrameDuration = fread(fid,1,'float');
BLKHeader.ValidFrames = fread(fid,1,'long');
BLKHeader.VdaqReserved = fread(fid,224,'*char')';

BLKHeader.TimeBlockStart = fread(fid,8,'ushort')';
BLKHeader.TimeBlockEnd = fread(fid,8,'ushort')';

% User-defined
BLKHeader.User = fread(fid,224,'*char')';

% Comment
BLKHeader.Comment = fread(fid,256,'*char')';

%% Verify file length
if ftell(fid)~=BLKHeader.LenHeader
  fclose(fid);
	error(['BLK header length doesn''t match the record in the file:', ...
         sprintf('\n%s\n',fnBLK),'Please check the file type!']);
end

fseek(fid,0,'eof');  % go to EOF
if ftell(fid)~=BLKHeader.FileSize
  fclose(fid);
	error(['BLK file length doesn''t match the record in the file:', ...
         sprintf('\n%s\n',fnBLK),'Please check the file type!']);
end

%% Close file
fclose(fid);


