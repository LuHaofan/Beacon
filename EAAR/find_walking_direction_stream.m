%direction_set = {};
R_total_sub = [1,0,0;0,1,0;0,0,1];
lists_sub = [];
for i  = 1:length(last_step)
    sample_sub = last_step(i,:);
    mag = norm(sample_sub);
    sample_sub = sample_sub/mag;
    theta = mag*1/100;
    quat(2)=sin(theta/2)*sample_sub(1);
    quat(3)=sin(theta/2)*sample_sub(2);
    quat(4)=sin(theta/2)*sample_sub(3);
    quat(1)=cos(theta/2);
    R = quat2rotm(quat);
    R_total_sub = R*R_total_sub;
    %R_total_list_sub{i}=R_total_sub;
    r_sub = vrrotmat2vec((R_total_sub))/pi*180;
    lists_sub = [lists_sub;r_sub];
end
len = length(lists_sub);
mid = floor(len / 2);
orientation_1 = atan2(lists_sub(mid,1)*sign(lists_sub(mid,4)),lists_sub(mid,2)*sign(lists_sub(mid,4)));
R_total_sub = [1,0,0;0,1,0;0,0,1];
lists_sub = [];
for i  = floor(length(last_step)/2):length(last_step)
    sample_sub = last_step(i,:);
    mag = norm(sample_sub);
    sample_sub = sample_sub/mag;
    theta = mag*1/100;
    quat(2)=sin(theta/2)*sample_sub(1);
    quat(3)=sin(theta/2)*sample_sub(2);
    quat(4)=sin(theta/2)*sample_sub(3);
    quat(1)=cos(theta/2);
    R = quat2rotm(quat);
    R_total_sub = R*R_total_sub;
    %R_total_list_sub{i}=R_total_sub;
    r_sub = vrrotmat2vec((R_total_sub))/pi*180;
    lists_sub = [lists_sub;r_sub];
end
orientation_2 =  atan2(lists_sub(mid,1)*sign(lists_sub(mid,4)),lists_sub(mid,2)*sign(lists_sub(mid,4)))+pi;
%figure(3);
orientation_list = [orientation_list,orientation_1/pi*180,orientation_2/pi*180];
%plot(orientation_list);
rotation_mtx = [cos(orientation_1),-sin(orientation_1);sin(orientation_1),cos(orientation_1)];
data_accel_local = [];
data_gyro_local = [];
for i = 1:length(last_step)
    data_accel_local(i,:) = (rotation_mtx*last_step_accel(i,1:2)')';
    data_gyro_local(i,:) = (rotation_mtx*last_step(i,1:2)')';
end

intg_angle = cumsum(data_gyro_local(:,2))/pi*180*0.01;
step_angle = intg_angle;
turn_angle = (max(step_angle)-min(step_angle))/2;
turn_angle_1 = (max(step_angle)-step_angle(1))/2;
turn_angle_2 = step_angle(floor(length(step_angle)/4))-step_angle(1);
turn_angle_3 = max(step_angle)-step_angle(floor(length(step_angle)/4));

%figure(2);plot(intg_angle);drawnow;