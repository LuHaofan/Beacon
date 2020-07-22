clear all; clear; clc;

data = xlsread('AudioTestUltra_pocket.xlsx', 'a2:i29');
id = data(:, 1);
lo = data(:, 8);
hi = data(:, 9);
figure;
plot(id, lo);
hold on
plot(id, hi);
hold on
plot([7,7],[30, 45]);
hold off