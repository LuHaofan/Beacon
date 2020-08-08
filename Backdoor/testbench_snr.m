close all; clear; clc;
snrVec = zeros(1,10);
for i = 1:10
    recObj = audiorecorder(48000, 24, 1);
    disp('Start Recording');
    record(recObj);
    disp('Playing Backdoor signal');
    sender_demo(1, 1, 0.2, 4000, 3000, 0, 0);
    pause(2);
    disp('Stop Recording');
    stop(recObj);
    data = getaudiodata(recObj);

    snr = measureSNR(data);
    snrVec(i) = snr;
end
disp(mean(snrVec));
