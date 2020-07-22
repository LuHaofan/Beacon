close all; clear; clc;
recObj = audiorecorder(48000, 24, 1);
disp('Start Recording');
record(recObj);
disp('Playing Backdoor signal');
startFreq = 36000;  %The ultrasound frequency after upconversion
bandwidth = 0;
duration = 0.6;
sender_demo(1, 1, duration, 40000-startFreq,bandwidth, 0, 0);
disp('Stop Recording');
stop(recObj);
t = 0:1/48000:duration;
sig = chirp(t, 4000, duration, 4000);
data = getaudiodata(recObj);
figure; plot((1:length(data))/recObj.SampleRate, data);
figure; spectrogram(data, 1024, 512, 48000, 48000);
corr = xcorr(data, sig);
figure; plot(corr);