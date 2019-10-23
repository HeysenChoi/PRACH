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
prach.PreambleIdx = 20;    % Preamble index: TS36.141, Table A.6-1
%%
info = ltePRACHInfo(ue, prach)
zcz = (info.NCS/info.NZC)*info.SamplingRate/info.SubcarrierSpacing;     % cyclic shift in sample numbers
deadzone=info.SamplingRate/(info.NZC*info.SubcarrierSpacing)/zcz;

Fs = (15000)*2048;
start=(info.Fields(1)+info.Fields(2))/Fs*info.SamplingRate;
duration=info.Fields(3)/Fs*info.SamplingRate;
%% Channel
chcfg.NRxAnts = 1;                       % Number of receive antenna
chcfg.DelayProfile = 'ETU';              % Delay profile
chcfg.DopplerFreq = 200.0;                % Doppler frequency
chcfg.MIMOCorrelation = 'Low';           % MIMO correlation
chcfg.Seed = 0;                          % Channel seed
chcfg.NTerms = 16;                       % Oscillators used in fading model
chcfg.ModelType = 'Dent';               % Rayleigh fading model type
chcfg.InitPhase = 'Random';              % Random initial phases
chcfg.NormalizePathGains = 'On';         % Normalize delay profile power
chcfg.NormalizeTxAnts = 'On';            % Normalize for transmit antennas
chcfg.SamplingRate = info.SamplingRate;  % Sampling rate
chcfg.InitTime = (1-1)/1000;            % in seconds
%%  Received
delay = 20;     % CP samples = info.Fields(2)/16 = 198. max delay should be less than < zcz
txwave = ltePRACH(ue, prach);
txwave = [zeros(delay,1);txwave];

%% Local reference preamble
refPRACH=ltePRACH(ue,prach);
[corr_ifft_tx, offset_tx] = corrIFFT(start, duration, txwave,refPRACH); % Ideal without fading channel

interference = 0;
for i = 1 : n_sim
    [rxwave, fadinginfo] = lteFadingChannel(chcfg,[txwave; zeros(25, 1)]);
    rxwave = rxwave((fadinginfo.ChannelFilterDelay + 1):end, :);

%     %%  correlator
%     [corr_ifft, offset] = corrIFFT(start,duration,rxwave,refPRACH);
%     offset
%     %% in time domain
%     xcorr_Time = abs(xcorr(txwave(start+(1:duration)),refPRACH(start+(1:duration)))).^2;    % directily correlation in time domation
%     xcorr_Time = xcorr_Time(duration:end);

    %% Interference preamble
    prachInf = prach;
    prachInf.PreambleIdx = 22;
    prachInf.SeqIdx = 0;
    [InfPRACH, info_inf] = ltePRACH(ue,prachInf);
    [corr_ifft_inf, offset_inf] = corrIFFT(start, duration, rxwave,InfPRACH); 

    interference = interference + corr_ifft_inf(delay+1);
    i/n_sim
end
interf = interference/n_sim
% %% Plot
% plot(corr_ifft,'Color','r','LineWidth',1.5)
% hold on
% plot(corr_ifft_tx,'Color','k','LineWidth',1.5)
% plot(corr_ifft_inf,'Color','b','LineWidth',1.5)


