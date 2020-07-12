close all; clear; clc;
fname = 'AudioTestUltraFilter.xlsx';
cases = xlsread(fname, 'd2:g257');
caseshape = size(cases);
ccVec = zeros(caseshape(1), 1);
for i = (1:caseshape(1))
    startFreq = cases(i,1)*1000;
    bandwidth = cases(i,2)*1000;
    duration = cases(i,4);
    disp('Running Test case:');
    disp('Start Frequency = ');
    disp(startFreq);
    disp('Bandwidth = ');
    disp(bandwidth);
    disp('Duration = ');
    disp(duration);
    cc = measureCC(0.5, startFreq, bandwidth, 0, 0);
%     figure; plot(cc)
    ccVec(i) = max(cc);
    pause(4);
end

xlswrite(fname, ccVec, 'h2:h257');