close all; clear; clc;
startFreq = 36000;  %The ultrasound frequency after upconversion
bandwidth = 1000;
duration = 0.2;
fname = 'mobilechirp.wav';
[data fs]= audioread(fname);
ch1 = data(:,1);
ch2 = data(:,2);
t = 0:1/fs:0.2;
signal = chirp(t, 4000, 0.2, 3000);
corr = xcorr(ch1, signal);
x = 3e5/fs:1/fs:length(corr)/fs;
figure; plot(x, corr(3e5:length(corr)));