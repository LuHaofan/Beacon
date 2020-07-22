close all; clear; clc;
fname = 'AudioTestUltra_pocket.xlsx';
cases = xlsread(fname, 'd14:g25');
caseshape = size(cases);
ccVec = zeros(caseshape(1), 1);
detVec = zeros(caseshape(1),1);
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
    cc = measureCC(duration, startFreq, bandwidth, 0, 0,1);
    figure; plot(cc)
    %title('Start Frequency:'+num2str(startFreq)+' Bandwidth:'+num2str(bandwidth));
    [detectable m_cc] = detectSignal(cc);
    %disp(m_cc);
    detVec(i) = detectable;
    title(num2str(detectable));
    ccVec(i) = m_cc;
    disp('Pausing...');
    pause(5);
end

%%xlswrite(fname, ccVec, 'h3:h30');
%xlswrite(fname, detVec, 'k2:k13');