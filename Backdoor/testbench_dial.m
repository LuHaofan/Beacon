close all; clear; clc;


dialNumber('7', 300);

% while(1)
% recObj = audiorecorder(48000, 24, 1);
% disp('Start Recording');
% record(recObj);
% disp('Playing Backdoor signal');
% 
% dialNumber('7', 0.2);
% pause(2);
% disp('Stop Recording');
% stop(recObj);
% data = getaudiodata(recObj);
% code = decodeTone(data);
% disp(char(code));
% % n_samples = 2;
% % slice = 1:length(data)/n_samples:length(data);
% % codeVec = zeros(1, length(slice)-1);
% % %figure; spectrogram(data, 1024, 512, 48000, 48000)
% % for i = 1:(length(slice)-1)
% %     codeVec(i) = decodeTone(data(slice(i):slice(i+1)));
% % end
% % 
% % %code = decodeTone(data);
% % for i = 1:length(codeVec)
% %     disp(char(codeVec(i)));
% % end
% pause(2);
% end

