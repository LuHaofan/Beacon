close all; clear; clc;
snrVec = zeros(1,10);
duration = 0.2;
for i = 1:10
    recObj = audiorecorder(48000, 24, 1);
    disp('Start Recording');
    record(recObj);
    disp('Playing Backdoor signal');
    sender_demo(1, 1, duration, 4000, 3000, 0, 0);
    pause(2);
    disp('Stop Recording');
    stop(recObj);
    data = getaudiodata(recObj);
    %figure; spectrogram(data, 1024, 512, 48000, 48000)
    snr = measureSNR(data, duration);
    snrVec(i) = snr;
end
disp(mean(snrVec));
