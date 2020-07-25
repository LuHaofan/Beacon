%close all;
cal_pt = [5,14];
%cal_pt = 5;
gnd_recursive = repmat(gnd_true_list,5,1);
gnd_temp = gnd_recursive(1:size(gnd_soft_list,1),:);
temp_list = [gnd_soft_list,gnd_temp];
err_list = vecnorm((temp_list(:,1:2)-temp_list(:,3:4))');
plot(gnd_time_list,err_list);
hold on;
plot(gnd_time_list(cal_pt+1),err_list(cal_pt+1),'ko','MarkerSize',12);
ylabel('Error (m)');
xlabel('Time (s)');

