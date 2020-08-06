close all; clear; clc;
startFreq = 33000;  %The ultrasound frequency after upconversion
bandwidth = 2000;
duration = 0.2;
% recObj = audiorecorder(48000, 24, 1);
% disp('Start Recording');
% record(recObj);
disp('Playing Backdoor signal');
% Periodically send the backdoor signal
i = 0;
while(1)
    sender_demo(1, 100, duration, 40000-startFreq,bandwidth, 0, 0);
    i = i + 1;
end

% disp('Stop Recording');
% stop(recObj);
% t = 0:1/48000:duration;
% sig = chirp(t, 4000, duration, 1000);
% data = getaudiodata(recObj);
% figure; plot((1:length(data))/recObj.SampleRate, data);
% figure; spectrogram(data, 1024, 512, 48000, 48000);
% corr = xcorr(data, sig);
% figure; plot(corr);