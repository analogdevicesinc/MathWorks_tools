function [validBeacon, mpdu, validPacket] = nonHTBeaconRxMPDUDecode(payload)
% nonHTBeaconRxMPDUDecode Checks if the payload input is from a beacon
% packet and returns its MPDU information. This is a helper function for
% the non-HT beacon receiver example.
% 
%   [VALIDBEACON, MPDU] = nonHTBeaconRxMPDUDecode(PAYLOAD) checks the
%   PAYLOAD binary input and sets VALIDBEACON to be true if PAYLOAD is from
%   a beacon packet. The MPDU information is also returned, but it is
%   meaningful only when VALIDBEACON is true.

% Copyright 2015-2016 The MathWorks, Inc.

%#codegen

coder.extrinsic('warning')

persistent crcDetector defaultMPDU

% Frame check sequence (FCS)
if isempty(crcDetector)
    crcDetector = comm.CRCDetector( ...
        [32 26 23 22 16 12 11 10 8 7 5 4 2 1 0], ...
        'InitialConditions', 1, ...
        'DirectMethod',      true, ...
        'FinalXOR',          1);
    defaultMPDU.Header = parseMPDUHeader(zeros(64,1), 1);
    defaultMPDU.FrameBody = unknownMPDU();
end

% Predefine output
validBeacon = false;
mpdu = defaultMPDU;
validPacket = false;

% If the CRC for the header decodes correctly (i.e. CRC flag is 0) and the
% received MPDU payload length is greater than or equal to the expected
% length, then turn on the MPDU decoder
if (length(payload) >= 32+16)
    % Compute CRC based on IEEE Std 802.11(TM)-2007 section 7.1.3.7.
    [frame, mpduCRCd] = crcDetector(double(payload));
    mpduCRC = mpduCRCd > 0; % Convert to logical
    
    % Extract header information
    [mpdu.Header, mpduHeaderLen] = parseMPDUHeader(frame, mpduCRC);
    
    validPacket = mpduCRC == 0;
    
    % Evaluate frame body
    if (mpduCRC == 1) || ((mpdu.Header.FrameCtrl.Type ~= 0) ...
            || (mpdu.Header.FrameCtrl.Subtype ~= 8))
        mpdu.FrameBody = unknownMPDU();
    else
        validBeacon = true;
        mpdu.FrameBody = parseBeaconMPDU(frame(mpduHeaderLen+1:end, 1), mpduCRC);
    end    
end

end

function [mpduHeader, len] = parseMPDUHeader(frame, mpduCRC)
% Based on IEEE Std 802.11-2007 chapter 7.

mpduHeader.FrameCtrl       = parseFrameControl(frame(1:16,1), mpduCRC);
mpduHeader.DurationID      = zeros(1,2,'uint8');
mpduHeader.Address1        = zeros(1,6,'uint8');
mpduHeader.Address2        = zeros(1,6,'uint8');
mpduHeader.Address3        = zeros(1,6,'uint8');
mpduHeader.SequenceControl = zeros(1,2,'uint8');
mpduHeader.Address4        = zeros(1,6,'uint8');
len = (2+6+6+6+2+6)*8 + 16;

if (mpduCRC == 0)
    p = 1;
    mpduHeader.FrameCtrl  = parseFrameControl(frame(p:p+15,1), mpduCRC);
    p = p+16;
    mpduHeader.DurationID = bit2Octet(frame(p:p+15,1),2);
    p = p+16;
    mpduHeader.Address1   = bit2Octet(frame(p:p+47,1),6);
    p = p+48;
    
    isManagementFrame = (mpduHeader.FrameCtrl.Type == 0);
    isControlFrame = (mpduHeader.FrameCtrl.Type == 1);
    isDataFrame = (mpduHeader.FrameCtrl.Type == 2);
    isCTSFrame = isControlFrame && (mpduHeader.FrameCtrl.Subtype == 12);
    isACKFrame = isControlFrame && (mpduHeader.FrameCtrl.Subtype == 13);
    
    if ~(isCTSFrame || isACKFrame)
        mpduHeader.Address2 = bit2Octet(frame(p:p+47,1),6);
        p = p+48;
    end
    if isManagementFrame
        mpduHeader.Address3 = bit2Octet(frame(p:p+47,1),6);
        p = p+48;
    end
    if ~isControlFrame
        mpduHeader.SequenceControl = bit2Octet(frame(p:p+15,1),2);
        p = p+16;
    end
    if isDataFrame
        mpduHeader.Address4 = bit2Octet(frame(p:p+47,1),6);
        p = p+48;
    end
    len = p-1;
end
end

function frameCtrl = parseFrameControl(fcBits, mpduCRC)
if (mpduCRC == 0)
    frameCtrl.ProtocolVersion = uint8(bi2de(fcBits(1:2,1)'));
    frameCtrl.Type            = uint8(bi2de(fcBits(3:4,1)'));
    frameCtrl.Subtype         = uint8(bi2de(fcBits(5:8,1)'));
    frameCtrl.ToDS            = uint8(bi2de(fcBits(9,1)'));
    frameCtrl.FromDS          = uint8(bi2de(fcBits(10,1)'));
    frameCtrl.MoreFragments   = uint8(bi2de(fcBits(11,1)'));
    frameCtrl.Retry           = uint8(bi2de(fcBits(12,1)'));
    frameCtrl.PowerManagement = uint8(bi2de(fcBits(13,1)'));
    frameCtrl.MoreData        = uint8(bi2de(fcBits(14,1)'));
    frameCtrl.ProtectedFrame  = uint8(bi2de(fcBits(15,1)'));
    frameCtrl.Order           = uint8(bi2de(fcBits(16,1)'));
else
    frameCtrl.ProtocolVersion = uint8(0);
    frameCtrl.Type            = uint8(0);
    frameCtrl.Subtype         = uint8(0);
    frameCtrl.ToDS            = uint8(0);
    frameCtrl.FromDS          = uint8(0);
    frameCtrl.MoreFragments   = uint8(0);
    frameCtrl.Retry           = uint8(0);
    frameCtrl.PowerManagement = uint8(0);
    frameCtrl.MoreData        = uint8(0);
    frameCtrl.ProtectedFrame  = uint8(0);
    frameCtrl.Order           = uint8(0);
end
end

function frameBody = parseBeaconMPDU(frame, mpduCRC)
if (mpduCRC == 0)
    bitCount = uint32(1);
    frameBody.TimeStamp      = bit2Octet(frame(bitCount:bitCount+63,1),8);
    bitCount = bitCount + 64;
    frameBody.BeaconInterval = bit2Octet(frame(bitCount:bitCount+15,1),2);
    bitCount = bitCount + 16;
    frameBody.Capability     = parseCapabilities(frame(81:96), mpduCRC);
    bitCount = bitCount + 16;
else
    frameBody.TimeStamp      = zeros(1,8,'uint8');
    frameBody.BeaconInterval = zeros(1,2,'uint8');
    frameBody.Capability     = parseCapabilities(frame(81:96), mpduCRC);
    bitCount = uint32(97);
end

frameLength = length(frame);

frameBody.NumInfoElements = uint8(0);
macElementStruct = struct('ID', uint8(255), ...
    'Length', uint8(0), ...
    'Value', zeros(1,257,'uint8'));
frameBody.InfoElements = repmat(macElementStruct, 1, 60);

if (mpduCRC == 0)
    while bitCount < frameLength
        frameBody.NumInfoElements = frameBody.NumInfoElements + 1;
        frameBody.InfoElements(frameBody.NumInfoElements).ID = ...
            bit2Octet(frame(bitCount:bitCount+7,1), 1);
        bitCount = bitCount + 8;
        elemLength = bit2Octet(frame(bitCount:bitCount+7,1), 1);
        frameBody.InfoElements(frameBody.NumInfoElements).Length = elemLength;
        bitCount = bitCount + 8;
        for p=1:elemLength
            frameBody.InfoElements(frameBody.NumInfoElements).Value(p) = ...
                bit2Octet(frame(bitCount:bitCount+7),1);
            bitCount = bitCount+8;
        end
    end
end
end

function capability = parseCapabilities(frame, mpduCRC)
if (mpduCRC == 0)
    capability.ESS                = frame(1,1);
    capability.IBSS               = frame(2,1);
    capability.CFPollable         = frame(3,1);
    capability.CFPollRequest      = frame(4,1);
    capability.Privacy            = frame(5,1);
    capability.ShortPreamble      = frame(6,1);
    capability.PBCC               = frame(7,1);
    capability.ChannelAgility     = frame(8,1);
    capability.SpectrumManagement = frame(9,1);
    capability.QoS                = frame(10,1);
    capability.ShortSlotTime      = frame(11,1);
    capability.APSD               = frame(12,1);
    capability.Reserved           = frame(13,1);
    capability.DSSOFDM            = frame(14,1);
    capability.DelayedBlockAck    = frame(15,1);
    capability.ImmediateBlockAck  = frame(16,1);
else
    capability.ESS                = double(false);
    capability.IBSS               = double(false);
    capability.CFPollable         = double(false);
    capability.CFPollRequest      = double(false);
    capability.Privacy            = double(false);
    capability.ShortPreamble      = double(false);
    capability.PBCC               = double(false);
    capability.ChannelAgility     = double(false);
    capability.SpectrumManagement = double(false);
    capability.QoS                = double(false);
    capability.ShortSlotTime      = double(false);
    capability.APSD               = double(false);
    capability.Reserved           = double(false);
    capability.DSSOFDM            = double(false);
    capability.DelayedBlockAck    = double(false);
    capability.ImmediateBlockAck  = double(false);
end
end

function frameBody = unknownMPDU()
frameBody.TimeStamp      = zeros(1,8,'uint8');
frameBody.BeaconInterval = zeros(1,2,'uint8');
frameBody.Capability     = parseCapabilities(zeros(16,1), 1);

frameBody.NumInfoElements = uint8(0);
macElementStruct = struct('ID', uint8(255), ...
    'Length', uint8(0), ...
    'Value', zeros(1,257,'uint8'));
frameBody.InfoElements = repmat(macElementStruct, 1, 60);
end

function octets = bit2Octet(bits,numOctets)
octets = zeros(1, numOctets, 'uint8');
for p=1:numOctets
    octets(1,p) = (bits((p-1)*8+1:p*8)')*2.^(0:7)';
end
end
