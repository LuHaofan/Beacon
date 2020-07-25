%err_cal_temp;
%close all;
cal_pt = [5,14];
%cal_pt = 5;
index_1 = [];
index_2 = [];
curser_list_raw_new = [curser_list_raw(1:prev_calibrated_ptr,:);curser_list(prev_calibrated_ptr+1:end,:)];
index_11 = find(abs(curser_list(:,1)-calib_pt_list(2,1))<0.001);
index_12 = find(abs(curser_list(:,2)-calib_pt_list(2,2))<0.001);
index_21 = find(abs(curser_list(:,1)-calib_pt_list(3,1))<0.001);
index_22 = find(abs(curser_list(:,2)-calib_pt_list(3,2))<0.001);
if(index_11 == index_12)
    index_1 = index_11;
end
if(index_21 == index_22)
    index_2 = index_21;
end
gnd_pt_index = [];
for i = 1:length(gnd_soft_list(:,1))
    gnd_pt_index = [gnd_pt_index,find(curser_list_raw_new(:,2)==gnd_soft_list(i,2))]
end
curser_list_unwrap = [curser_list_raw_new(1:index_1,:);
    curser_list_raw_new(index_1+1:index_2,:)+curser_list_raw_new(index_1-1,:)-curser_list(index_1-1,:);    curser_list_raw_new(index_2+1:end,:)+curser_list_raw_new(index_1-1,:)-curser_list(index_1-1,:)+curser_list_raw_new(index_2-1,:)-curser_list(index_2-1,:)];
curser_list_hard = [curser_list_raw_new(1:index_1,:);
    curser_list_raw_new(index_1+1:index_2,:)-curser_list_raw_new(index_1+1,:)+[-3,1.8]; curser_list_raw_new(index_2+1:end,:)-curser_list_raw_new(index_2+1,:)+[-3.6,12]];
calib_vec = calib_pt_list(3,:)-calib_pt_list(2,:);
raw_vec = curser_list_raw_new(index_2,:) -curser_list_raw_new(index_1,:);
theta_off = atan2(raw_vec(2), raw_vec(1)) - ...
    atan2(calib_vec(2), calib_vec(1));
curser_list_temp = curser_list;
curser_vec = curser_list(index_2:end,:)-curser_list(index_2,:);
cal_curser_vec = curser_vec...
            *[cos(direction_offset),-sin(direction_offset);
            sin(direction_offset),cos(direction_offset)];
curser_list_temp(index_2:end,:) = curser_list(index_2,:)...
    + cal_curser_vec;


gnd_hard_list = curser_list_hard(gnd_pt_index,:);
gnd_raw_list = curser_list_unwrap(gnd_pt_index,:);
gnd_none_casual_list = curser_list(gnd_pt_index,:);
gnd_soft_1_list = curser_list_temp(gnd_pt_index,:);

gnd_recursive = repmat(gnd_true_list,5,1);
gnd_temp = gnd_recursive(1:size(gnd_soft_list,1),:);
err_raw_list = vecnorm((gnd_raw_list-gnd_temp)');
err_hard_list = vecnorm((gnd_hard_list-gnd_temp)');
err_none_casual = vecnorm((gnd_none_casual_list-gnd_temp)');
err_soft_1 = vecnorm((gnd_soft_1_list-gnd_temp)');
plot(err_list);
hold on;
plot(err_raw_list);
plot(err_hard_list);
plot(err_none_casual);
plot(err_soft_1);
legend('soft','raw','hard','nc','soft1');
%hold on;
%plot(gnd_time_list(cal_pt+1),err_list(cal_pt+1),'ko','MarkerSize',12);
%ylabel('Error (m)');
%xlabel('Time (s)');

