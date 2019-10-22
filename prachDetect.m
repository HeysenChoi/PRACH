clc
clear

ue.NULRB = 6;                   % 6 Resource Blocks
ue.DuplexMode = 'FDD';          % Frequency Division Duplexing (FDD)
ue.CyclicPrefixUL = 'Normal';   % Normal cyclic prefix length
ue.NTxAnts = 1;                 % Number of transmission antennas

prach.Format = 0;          % PRACH format: TS36.104, Table 8.4.2.1-1
prach.SeqIdx = 22;         % Logical sequence index: TS36.141, Table A.6-1
prach.CyclicShiftIdx = 1;  % Cyclic shift index: TS36.141, Table A.6-1
prach.HighSpeed = 0;       % Normal mode: TS36.104, Table 8.4.2.1-1
prach.FreqOffset = 0;      % Default frequency location
prach.PreambleIdx = 32;    % Preamble index: TS36.141, Table A.6-1
info = ltePRACHInfo(ue, prach)
foffset = 250;

chcfg.NRxAnts = 1;                       % Number of receive antenna
chcfg.DelayProfile = 'ETU';              % Delay profile
chcfg.DopplerFreq = 200.0;                % Doppler frequency
chcfg.MIMOCorrelation = 'Low';           % MIMO correlation
chcfg.Seed = 1;                          % Channel seed
chcfg.NTerms = 16;                       % Oscillators used in fading model
chcfg.ModelType = 'GMEDS';               % Rayleigh fading model type
chcfg.InitPhase = 'Random';              % Random initial phases
chcfg.NormalizePathGains = 'On';         % Normalize delay profile power
chcfg.NormalizeTxAnts = 'On';            % Normalize for transmit antennas
chcfg.SamplingRate = info.SamplingRate;  % Sampling rate
chcfg.InitTime = (1-1)/1000;
ulinfo = lteSCFDMAInfo(ue);
SNRdB = -5;
SNR = 10^(SNRdB/20);
N = 1/(SNR*sqrt(double(ulinfo.Nfft)))/sqrt(2.0);
Fs = (15000)*2048;
start=(info.Fields(1)+info.Fields(2))/Fs*info.SamplingRate;
duration=info.Fields(3)/Fs*info.SamplingRate;
delay = 100;

txwave = ltePRACH(ue, prach);
txwave = [zeros(delay,1);txwave];
%%
[rxwave, fadinginfo] = lteFadingChannel(chcfg,[txwave; zeros(25, 1)]);
fadinginfo

noise = N*complex(randn(size(rxwave)), randn(size(rxwave)));
rxwave = rxwave + noise;

rxwave = rxwave((fadinginfo.ChannelFilterDelay + 1):end, :);
t = ((0:size(rxwave, 1)-1)/chcfg.SamplingRate).';
rxwave = rxwave .* exp(1i*2*pi*foffset*t);

prachRef = prach;
prachRef.PreambleIdx = 32;        
refPRACH=ltePRACH(ue,prachRef);
refPRACH=refPRACH(start+(1:duration));
refPRACHFFT = fft(refPRACH);

rx = rxwave(start+(1:duration),1);
rxFFT=fft(rx);

corr = rxFFT.*conj(refPRACHFFT);
corrIFFT = abs(ifft(corr)).^2;

delay
time_offset = find(corrIFFT == max(corrIFFT)) - 1

plot(corrIFFT);
% [detected, offsets] = ltePRACHDetect(ue, prach, rx, (0:63).')
