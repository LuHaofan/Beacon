% close all; clear; clc;
% t = 0: 1/48000: 0.5;
% s = chirp(t,1000, 0.5, 3000);
% fft_s = abs(fft(s));
% rfft_s = fft_s(1:(floor(length(fft_s)/2)+1));
% figure; plot(rfft_s);
% 
% r = chirp(t, 1000, 0.5, 3000);
% fft_r = abs(fft(r));
% rfft_r = fft_s(1:(floor(length(fft_r)/2)+1));
% fcc = xcorr(rfft_s, rfft_r);
% figure; plot(fcc);
%% IFFT test
f = 1000:1/10:3000;
hs = sin(f);
figure; plot(f, hs);
ys = ifft(hs);
t = 0:length(ys)-1;
figure; plot(t, abs(ys));
sound(abs(ys), 48000);
pause(2)
%% Function 
function cc = frequencyCC(f_start, bandwidth,rfft_data, duration)
    t = 0:1/48000:duration;
    s = chirp(t, f_start, duration, f_start+bandwidth);
    fft_s = abs(fft(s));
    rfft_s = fft_s(1:(floor(length(fft_s)/2)+1));
    cc = xcorr(rfft_data, rfft_s);
end