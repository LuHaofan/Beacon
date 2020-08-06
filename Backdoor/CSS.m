close all; clear; clc;
% startF = 0;
% endF = 5000;
% duration = 0.5;
% t = 0:1/48000:duration;
% alpha = (endF-startF)/duration;
% f = alpha.*t+startF;
% figure; plot(f)
% signal0 = cos(2*pi*alpha/2.*t.^2-2*pi*startF.*t);
% %signal0 = exp(i*2*pi*alpha/2.*t.^2-i*2*pi*startF.*t-pi/2);
% figure; plot(t,signal0);
% figure; spectrogram(signal0, 1024, 512, 48000, 48000);
% signal1 = exp(2*pi*alpha/2.*t.^2);
% %signal1 = exp(i*2*pi*alpha/2.*t.^2);
% figure; spectrogram(signal1, 1024, 512, 48000, 48000);
duration = 0.07;
t = 0:1/48000:duration;
s1 = chirp(t, 1000, duration, 2000);
s2 = chirp(t, 2000, duration, 3000);
s3 = chirp(t, 4000, duration, 3000);
s = cat(2, s1, s2);
s = cat(2, s, s3);
% corr = xcorr(s, s1);
% figure; plot(corr);
figure; spectrogram(s, 1024, 512, 48000, 48000);

r1 = chirp(t, 1000, duration, 2000);
r2 = chirp(t, 2000, duration, 3000);
r3 = chirp(t, 4000, duration, 3000);
r = cat(2, r1, r2);
r = cat(2, r, r3);
figure; spectrogram(r, 1024, 512, 48000, 48000);
corr = xcorr(s, r);

figure; plot(corr);
[max_corr max_idx] = max(corr);
disp(max_corr);
disp(max_idx);

