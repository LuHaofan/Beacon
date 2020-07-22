close all; clear; clc;
startFreq = 36000;  %The ultrasound frequency after upconversion
bandwidth = 3000;
duration = 0.1;
[data, fs] = audioread('walkingtest.wav');
seg = data(1:6*fs, 1);
t = 0:1/48000:duration;
signal = chirp(t, 4000, duration, 1000);
figure; spectrogram(seg, 1024, 512, fs, fs);
corr = xcorr(seg, signal);
figure;plot(corr);