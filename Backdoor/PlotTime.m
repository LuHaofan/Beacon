close all; clear; clc;
data = xlsread('AudioTestUltra_time.xlsx', 'd2:h36');
startFreq=data(:,1);bandwidth=data(:,2);duration = data(:,4);crosscorr=data(:,5);
[X,Y] = meshgrid(linspace(min(startFreq),max(startFreq)),linspace(min(duration),max(duration)));
Z=griddata(startFreq,duration,crosscorr,X,Y);%²åÖµ
figure;mesh(X,Y,Z);
xlabel('Start Frequency (kHz)');
ylabel('Duration');
zlabel('Cross-correlation');