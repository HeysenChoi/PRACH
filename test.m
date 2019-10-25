clc
clear

n_sim = 100;

%% parameters
ue.NULRB = 6;                   % 6 Resource Blocks
ue.DuplexMode = 'FDD';          % Frequency Division Duplexing (FDD)
ue.CyclicPrefixUL = 'Normal';   % Normal cyclic prefix length
ue.NTxAnts = 1;                 % Number of transmission antennas

prach.Format = 0;          % PRACH format: TS36.104, Table 8.4.2.1-1
prach.SeqIdx = 0;         % Logical sequence index: TS36.141, Table A.6-1
prach.CyclicShiftIdx = 1;  % Cyclic shift index: TS36.141, Table A.6-1
prach.HighSpeed = 0;       % Normal mode: TS36.104, Table 8.4.2.1-1
prach.FreqOffset = 0;      % Default frequency location
prach.PreambleIdx = 0;    % Preamble index: TS36.141, Table A.6-1
%%
info = ltePRACHInfo(ue, prach);
zcz = (info.NCS/info.NZC)*info.SamplingRate/info.SubcarrierSpacing;     % cyclic shift in sample numbers
deadzone=info.SamplingRate/(info.NZC*info.SubcarrierSpacing)/zcz;

Fs = (15000)*2048;
start=(info.Fields(1)+info.Fields(2))/Fs*info.SamplingRate;
duration=info.Fields(3)/Fs*info.SamplingRate;

%%  Transmitted 
delay = 10;     % CP samples = info.Fields(2)/16 = 198. max delay should be less than < zcz
txwave = ltePRACH(ue, prach);
downsampling = 1536/info.NZC;
txwave_down = txwave(start+(1:duration),1);
txwave_down = txwave_down(1:floor(downsampling):end);

zc = zadoffChuSeq(info.RootSeq,info.NZC);