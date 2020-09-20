close all; clear; clc;

[y Fs] = audioread('Real.wav');
data = y(:,1);
len = length(data);
duration = 0.2;
seg_len = Fs*duration;
idx = 1;
maxSNRVec = [];
while (idx < len-seg_len)
    seg = data(idx:idx+seg_len);
    snr = measureSNR(seg, duration);
    maxSNRVec = [maxSNRVec, max(snr)];
    idx = idx+seg_len/20;
end
tVec = [];
for i = 1:length(maxSNRVec)
    tVec = [tVec, 0.01*i];
end
[yupper,ylower] = envelope(maxSNRVec,200,'peak');
figure();
plot(tVec, yupper);
hold on;
plot(tVec, maxSNRVec);
hold off;
xlabel('Time(s)');
ylabel('SNR');
title('Plot of the maximum SNR for each segment of time');
legend('envelop','SNR data');

