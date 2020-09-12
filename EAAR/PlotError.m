close all; clear; clc;

load curser_list_real_ground_truth_tone;

truth_y_1 = (0:0.2:16.6)';
truth_x_1 = zeros(length(truth_y_1),1);
truth_x_2 = (0:-0.2:-5)';
truth_y_2 = 16.6*ones(length(truth_x_2),1);
truth_y_3 = (16.6:-0.2:0)';
truth_x_3 = -5*ones(length(truth_y_3),1);
truth_x_4 = (-5:0.2:0)';
truth_y_4 = zeros(length(truth_x_4),1);

truth_x = cat(1,truth_x_1,truth_x_2,truth_x_3,truth_x_4);
truth_y = cat(1,truth_y_1,truth_y_2,truth_y_3,truth_y_4);
truth_list = cat(2,truth_x,truth_y);
figure;
plot(truth_x,truth_y);
hold on;
plot(curser_list(1:110,1),curser_list(1:110,2), '-*');
hold on;
scatter([0,-2.16,-5],[8.3,16.6,8.3],'k','^');
xlim([-10,10]);
ylim([-1,25]);
hold off;

errVec = [];
for i = (1:110)
    errVec = [errVec, find_closest(curser_list(i,1),curser_list(i,2),truth_list)];
end
figure;
plot(errVec);
xlabel('step');
ylabel('Error');
function err = find_closest(x, y, truth_list)
    err = 625;
    for i = 1:length(truth_list)
        tmp = (x-truth_list(i,1))^2+(y-truth_list(i,2))^2;
        if tmp < err
            err = tmp;
        end
    end
end

