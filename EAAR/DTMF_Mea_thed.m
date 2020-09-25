close all; clear; clc;

[y Fs] = audioread('../DTMF_Test_Recordings/crowd noise.wav');
%[y_dtmf Fs] = audioread('../DTMF_Test_Recordings/step1.wav');
seg_len = 0.2*Fs;
seg_start = 1;
seg_end = length(y);
cur_seg = seg_start+seg_len;
segVec = [seg_start,seg_start+seg_len];
while(cur_seg<seg_end)
    segVec = [segVec; cur_seg, cur_seg+seg_len];
    cur_seg = cur_seg+seg_len+1;
end
disp(size(segVec));
F1 = [2100, 2400, 2700, 3000];
F2 = [4350, 4650, 4950, 5250];

FreqVec = [F1, F2];
idxVec = zeros(1,length(FreqVec));
N = seg_len;
zpad = 8*N;
f_samples = -Fs/2:Fs/zpad:Fs/2;
for i = 1:length(FreqVec)
    [tmp idxVec(i)] = min(abs(f_samples-FreqVec(i)));
end
ampVec = zeros(length(segVec), length(FreqVec));
for i = 1:length(FreqVec)
    for j = 1:length(segVec)
        fft_data = abs(dft(y(segVec(j,1):segVec(j,2)), length(f_samples)));
        ampVec(j,:) = fft_data(idxVec);
    end
end
avgVec = zeros(1,length(FreqVec));
maxVec = zeros(1,length(FreqVec));
minVec = zeros(1,length(FreqVec));
stdVec = zeros(1,length(FreqVec));
for i = 1:length(FreqVec)
    avgVec(i) = mean(ampVec(:,i));
    maxVec(i) = max(ampVec(:,i));
    minVec(i) = min(ampVec(:,i));
    stdVec(i) = std(ampVec(:,i));
end
disp(avgVec);
disp(maxVec);
disp(minVec);
disp(stdVec);
% for i = 1:length(segVec)
%     %figure;
%     dft_data = abs(dft(y(segVec(i,1):segVec(i,2)), 4*seg_len));
%     dft_data_dtmf = abs(dft(y_dtmf(segVec(i,1):segVec(i,2)), 4*seg_len));
%     f = linspace(-Fs/2,Fs/2,4*seg_len);
%     plot(f,dft_data);
%     hold on;
%     plot(f,dft_data_dtmf);
%     xlim([2000,5000]);
% end

function dft_data = dft(data, len)
    dft_data = fftshift(fft(data, len));
end