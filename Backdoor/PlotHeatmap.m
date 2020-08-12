close all; clear; clc;

data= xlsread('SNRData.xlsx','MobilePhoneInPocket');
x = data(:,3);
y = data(:,4);
snr = data(:,5);
[X,Y] = meshgrid(linspace(min(x),max(x)),linspace(min(y),max(y)));
Z=griddata(x,y,snr,X,Y);%��ֵ
figure;pcolor(X,Y,Z);shading interp%α��ɫͼ
hold on;
%scatter(0, 80);
title('SNR Heatmap of Backdoor signal phone in pocket');
hold off;
%legend('Human Body');