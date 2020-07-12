close all; clear; clc;
recObj = audiorecorder(48000, 24, 1);
disp('Start Recording');
record(recObj);
disp('Playing Backdoor signal');
startFreq = 15000;  %The ultrasound frequency after upconversion
bandwidth = 0;
sender_demo(1, 1, 0.5, 40000-startFreq,bandwidth, 0, 0);
disp('Stop Recording');
stop(recObj);

data = getaudiodata(recObj);
figure; plot((1:length(data))/recObj.SampleRate, data);
figure; spectrogram(data, 1024, 512, 48000, 48000);
