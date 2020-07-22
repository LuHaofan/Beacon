close all; clear; clc;
% data0 = xlsread('AudioTestUltra_80cm_0deg_pocket.xlsx', 'h2:h256');
% data15 = xlsread('AudioTestUltra_80cm_15deg_pocket.xlsx', 'h2:h256');
% data30 = xlsread('AudioTestUltra_80cm_30deg_pocket.xlsx', 'h2:h256');
% data45 = xlsread('AudioTestUltra_80cm_45deg_pocket.xlsx', 'h2:h256');
% data60 = xlsread('AudioTestUltra_80cm_60deg_pocket.xlsx', 'h2:h256');
% data75 = xlsread('AudioTestUltra_80cm_75deg_pocket.xlsx', 'h2:h256');
% data90 = xlsread('AudioTestUltra_80cm_90deg_pocket.xlsx', 'h2:h256');
% data_mat = [data0 data15 data30 data45 data60 data75 data90];
load data_mat;
t = xlsread('AudioTestUltra_80cm_0deg_pocket.xlsx', 'd2:g256');
i = 1;
for n_line = 160:165
    
    x = [0 15 30 45 60 75 90];
    subplot(2,3,i); plot(x, data_mat(n_line,:));
    xlabel('Degree');
    ylabel('Cross-correlation');
    title("Start Freq:"+num2str(t(n_line,1))+'   '+"Bandwidth:"+num2str(t(n_line,2)));
    i = i+1;
end