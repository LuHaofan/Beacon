close all; clear; clc;
data20 = xlsread('AudioTestUltra_dist.xlsx', 'h3:h38');
data80 = xlsread('AudioTestUltra_dist.xlsx', 'q3:q38');
data140 = xlsread('AudioTestUltra_dist.xlsx', 'z3:z38');
data180 = xlsread('AudioTestUltra_dist.xlsx', 'ai3:ai38');
data_dist = [data20 data80 data140 data180];
t = xlsread('AudioTestUltra_dist.xlsx', 'd3:g38');
i = 1;
for n_line = 22:27
    x = [20 80 140 180];
    subplot(2,3,i); plot(x, data_dist(n_line,:));
    xlabel('Distance');
    ylabel('Cross-correlation');
    title("Start Freq:"+num2str(t(n_line,1))+'   '+"Bandwidth:"+num2str(t(n_line,2)));
    i = i+1;
end