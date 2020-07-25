close all; clear; clc;
recObj = audiorecorder(48000, 24, 1);
disp('Start Recording');
record(recObj);
disp('Playing Backdoor signal');
encode(1);
pause(2);
disp('Stop Recording');
stop(recObj);
data = getaudiodata(recObj);

corr = xcorr()
