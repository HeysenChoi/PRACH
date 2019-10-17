clc
clear

%%% with LTE tool box
ue.DuplexMode = 'FDD';
ue.NULRB = 6;
chs.Format = 0;
chs.HighSpeed = 0;
chs.CyclicShiftIdx = 0;
chs.FreqOffset = 0;  %% the first resource block for PRACH
chs.SeqIdx = 0; %% logical root sequence index
chs.PreambleIdx =  0 ;

[prachSym,prachInfo] = ltePRACH(ue,chs);
prachInfo

%%%% without LTE tool box

Nzc = prachInfo.NZC;
root = prachInfo.RootSeq;
Ncp = prachInfo.Fields(2);
Nseq = prachInfo.Fields(3);
Nguard = prachInfo.Fields(4);
phi = prachInfo.Phi;

n = (0:Nzc-1)';
preamble = exp(-1i*pi*root*n.*(n+1)/Nzc);

Ts = 1/(15000 * 2048);  %% LTE unit time
Tsampling = 1 / (15000 * 128);  %% Sampling period = 1/samplingrate
scaling = Tsampling / Ts;
fsubPRACH = prachInfo.SubcarrierSpacing;
K = prachInfo.K;
k0 = chs.FreqOffset * 12 - ue.NULRB * 12/ 2;
beta = 7.6728e-05;             %% amplitude scaling factor. The value is determined by transmit power.
s = zeros (1/Tsampling/1000,1); 
for t = 0 : (Nseq+Ncp)/scaling - 1
    for k = 0 : Nzc - 1
        for n = 0 : Nzc -1
            s(t+1) = s(t+1) + preamble(n+1)*exp(-1j*2*pi*n*k/Nzc)*exp(1j*2*pi*(k+phi+K*(k0+1/2))*fsubPRACH*(t-Ncp/scaling)*Tsampling);
        end       
    end
    s(t+1) = beta * s(t+1);
    loading = t/((Nseq+Ncp)/scaling)*100
end
