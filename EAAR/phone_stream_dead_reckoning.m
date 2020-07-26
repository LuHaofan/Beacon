close all;
warning('off');
figure(1);
ButtonHandle = uicontrol('Style', 'PushButton', ...
    'String', 'Reset','Callback','delete(gcf)');
figure(2);
ButtonHandle_2 = uicontrol('Style', 'PushButton', ...
    'String', 'Calibrate','Callback','delete(gcf)');

anchor_list = [0, 0; -3,4];       % physical beacon position
calib_pt_list = [0, 6];         % recalibration point

t=tcpip('127.0.0.1', 10086,'NetworkRole','server');

% Wait for connection
disp('Waiting for connection');
%fopen(t);
disp('Connection OK');




global ready_to_type;
global key;
global key_stroke_time;
global total_time;
key_stroke_time=[];
key='a';
ready_to_type = false;
h_fig = figure(4);
set(h_fig,'KeyPressFcn',@mykeyfun);
time_stamp_step_list = [];

ori_bias = 0;
orientation_list_final = [];
%% ES offline
accel_esense_list = [];
R_total_es_list = {};

gnd_time_list = [];
gnd_time_list_sys = [];
while_time_list = [];
gnd_soft_list = [];
gnd_hard_list = [];
gnd_none_list = [];

cal_time_list = [];
time_stamp_step = 1;

turn_angle_list = [];
connector on 990707;
m=mobiledev;
discardlogs(m);
pause(0.5);
[gyro_l, ts_1] = angvellog(m);
[accel_l, ts_2] = accellog(m)
step_count = 0;
step_length = [];
%% Multiple list for diff. Cal.
curser_list = []; % soft cal. %每一步的坐标
curser_list_raw = zeros(10000,2); % no cal.
quat = [0,0,0,0];
list = [];
curser = [0,0];
count = 0;
R_total = [1,0,0;0,1,0;0,0,1];
R_total_list = {};
data = [];
accel_data = [];
orientation_list = [];
last_step_boundary_old = [0,0];
step_scale = 1;
direction_offset = 0;
leg_length_mean = 1.2;
pause(0.5);
[gyro_l, ts_1] = angvellog(m);
[accel_l, ts_2] = accellog(m);
pause(0.5);
curser_a_old = length(ts_2);
curser_g_old = length(ts_1);
curser_initial_a = curser_a_old;
curser_initial_g = curser_g_old;
uncalib_x = accel_l(curser_initial_a,1);
uncalib_y = accel_l(curser_initial_a,2);
uncalib_z = accel_l(curser_initial_a,3);
R_initial = vrrotvec2mat([-uncalib_y,uncalib_x,0,-atan2(sqrt(uncalib_x^2+uncalib_y^2),(uncalib_z))]);
%%%%%%%%%just for test


%%%%%%%%%%%%%%
%esense_init;
[accel_l, ts_2] = accellog(m);
time_phone_offset = ts_2(end);
abs_loc = [0, 0];
flag_calib  = 0;
prev_curser_calibrated=[0,0];
prev_calibrated_ptr = 1;
update_hidden = 1;

%tic;



while 1
%    total_time = toc;
%     disp(accel_l);
%     disp(gyro_l);
    while_time_list = [while_time_list; total_time];
    drawnow;
    if ~ishandle(ButtonHandle)
        disp('Resetting');
        row = randi(3); col = randi(4);
        sys_eval_gnd = [row,col];
        %AAR_obj = AAR_obj_list{row,col};
        %AAR_loc = squeeze(AAR_loc_list(row,col,:))';
        init_ptr = true;
        curser = [0,0];
        curser_list = [];
        prev_curser_calibrated=[0,0];
        prev_calibrated_ptr = 1;
        orientation_list_final = [];
        figure(1);
        clf(4);
        ButtonHandle = uicontrol('Style', 'PushButton', ...
            'String', 'Reset','Callback','delete(gcf)');
    end
    if ~ishandle(ButtonHandle_2)
        disp('Calibrating');
        figure(2);
        ButtonHandle_2 = uicontrol('Style', 'PushButton', ...
            'String', 'Calibrate','Callback','delete(gcf)');
        flag_calib = 1;
        calibrated_pt_id = -1;
    end
    % Read data from the socket
    if(t.BytesAvailable>0)
        calib_anchor_id = [];
        calib_anchor_id = fread(t, t.BytesAvailable);
        flag_calib = 1;
    end
    %flag_calib = 1;
    if flag_calib == 1
        %% Modified by Wally
        if calibrated_pt_id<1 % Not pre-set, find the closest cal_point
            
            dist_calib = [];
            for i_calib_pt = 1:size(calib_pt_list,1)
                dist_calib = [dist_calib,pdist2(calib_pt_list(i_calib_pt,:),curser)];
            end
            calibrated_pt_id = find(dist_calib==min(dist_calib));
            update_hidden = 0;
            curser_calibrated = calib_pt_list(calibrated_pt_id,:);
        else
            update_hidden = 0;
            curser_calibrated = anchor_list(calib_anchor_id,:);
        end
        vec_calibrated = curser_calibrated-prev_curser_calibrated;
        vec_uncal = curser-prev_curser_calibrated;
        if(vecnorm(vec_uncal)~=0)
            step_scale = vecnorm(vec_calibrated) / vecnorm(vec_uncal);
            direction_offset = -atan2(vec_calibrated(2),vec_calibrated(1))...
                +atan2(vec_uncal(2),vec_uncal(1));
            curser_vec = curser_list(prev_calibrated_ptr:end,:)-prev_curser_calibrated;
            cal_curser_vec = curser_vec...
                *[cos(direction_offset),-sin(direction_offset);...
                sin(direction_offset),cos(direction_offset)]*step_scale;
            CL = size(curser_list,1);
            curser_list_raw(prev_calibrated_ptr:CL,:) = curser_list(prev_calibrated_ptr:end,:);
            curser_list(prev_calibrated_ptr:end,:) = ...
                prev_curser_calibrated+cal_curser_vec;
            curser = curser_list(end,:);
            abs_loc = curser;
            if update_hidden
                leg_length_mean = leg_length_mean * step_scale;
                ori_bias = ori_bias + direction_offset;
            end
        end
        %clf(4);
        figure(4);
        plot(curser_list(:,1),curser_list(:,2),'-*');
        hold on;
        plot(curser_list(end,1),curser_list(end,2),'^');
        hold off;
        xlim([-10,10]);
        ylim([-3,25]);
        prev_curser_calibrated = curser_calibrated;
        prev_calibrated_ptr = length(curser_list);
        flag_calib = 0;
        % end modification
    end
    
    
    for i_time = 1:length(time_stamp_step_list)
        if ready_to_type && time_stamp_step_list(i_time) > key_stroke_time(1) + time_phone_offset 
            ready_to_type = false;
            disp('================');
            disp('SAMPLE COLLECTED');
            disp('================');
            sound(5*obj_ado, fs);
            gnd_time_list = [gnd_time_list; time_stamp_step_list(i_time)];
            gnd_time_list_sys = [gnd_time_list_sys; key_stroke_time(1)];
            gnd_soft_list = [gnd_soft_list; curser_list(i_time*2,:)];
            key_stroke_time(1) = [];
            break;
        end
        
    end
    
    
    
    %esense_loop;
    [gyro_l, ts_1] = angvellog(m);
    [accel_l, ts_2] = accellog(m);
    curser_a = length(accel_l);
    curser_g = length(gyro_l);
    ts_a = ts_2(curser_a-1)-ts_2(curser_initial_a);
    ts_g = ts_1(curser_g-1)-ts_1(curser_initial_g);
    ts = min(ts_a,ts_g);
    pos_a = find(ts_2-ts_2(curser_initial_a)>ts);
    curser_a = pos_a(1)-1;
    pos_g = find(ts_1-ts_1(curser_initial_g)>ts);
    curser_g = pos_g(1)-1;
    if(curser_g == curser_g_old)
        continue;
    end
    for i = curser_g_old-curser_initial_g+1:curser_g-curser_initial_g
        if(i+curser_initial_a-1>length(accel_l))
            curser_g = i+curser_initial_g-1;
            curser_a = i+curser_initial_a-1;
            continue;
        end
        sample = (R_initial*gyro_l(i+curser_initial_g-1,:)')';
        sample_accel = (R_initial*accel_l(i+curser_initial_a-1,:)')';
        if(i>1 && length(R_total_list)>=i-1)
            sample = (R_total_list{i-1}*sample')';
            sample_accel = (R_total_list{i-1}*sample_accel')';
        end
        accel_data = [accel_data; sample_accel];
        data = [data;sample];
        mag = norm(sample);
        sample = sample/mag;
        theta = mag*1/100;%(ts_1(i+curser_initial_g)-ts_1(i+curser_initial_g-1));
        quat(2)=sin(theta/2)*sample(1);
        quat(3)=sin(theta/2)*sample(2);
        quat(4)=sin(theta/2)*sample(3);
        quat(1)=cos(theta/2);
        R = quat2rotm(quat);
        count = count+1;
        R_total =R*R_total;
        R_total_list{i}=R_total;
        r = vrrotmat2vec((R_total))/pi*180;
        list = [list;r];
        curser_a_old = curser_a;
        curser_g_old = curser_g;
    end
    %    Q_plot = R_total*Q;
    %Q_plot = R_straight*R_initial*Q;
    %plot3(Q_plot(1,:),Q_plot(2,:),Q_plot(3,:)) % rotated cube
    %xlim([-2 2])
    %ylim([-2 2])
    %zlim([-2 2])
    %drawnow
    if(length(accel_data)>500)
        %figure(1);
        %hold off;
        %plot(accel_esense_list(3,end-150:end));
        %drawnow
%        accel_esense = accel_esense_list(:,end-150:end)';
        sample_accel = accel_data(end-500:end,:);
        sample_gyro = data(end-500:end,:);
        avg = conv(sample_accel(:,3),ones(100,1))/100;
   %     avg_esense = conv(accel_esense(:,3),ones(30,1))/30;
        avg = avg(50:end-50);
   %     avg_esense = avg_esense(15:end-15);
        %if(mean(sample_accel(:,3))<0)
        %    sample_accel(:,3) = -sample_accel(:,3);
        %    sample_accel(:,1) = -sample_accel(:,1);
        %end
        accel_v_zero_mean = sample_accel(:,3)-avg;
   %     accel_v_zero_mean_esense = accel_esense(:,3)-avg_esense;
        temp = accel_v_zero_mean;
        temp(1:51)=0;
        temp(450:500)=0;
   %     temp_esense = accel_v_zero_mean_esense;
   %     temp_esense(1:15) = 0;
   %     temp_esense(end-15:end) = 0;
        peak_height = std(temp)/1.5+mean(temp);
%        peak_height_esense = std(temp_esense)/2+mean(temp_esense);
        [pks, locs] = findpeaks(temp, 'MINPEAKHEIGHT', max(peak_height,3), 'MinPeakDistance', 80);
    %    [pks_esense, locs_esense] = findpeaks(temp_esense, 'MINPEAKHEIGHT', peak_height_esense, 'MinPeakDistance', 40);
        for i = 2:length(pks)-1
            temp_part = temp(locs(i)-20:locs(i)+20);
            [pks_part, locs_part] = findpeaks(temp_part, 'MINPEAKHEIGHT', peak_height);
            pos = find(locs_part==21);
            if(pos>1)
                pks(i)=pks_part(pos-1);
                locs(i)=locs_part(pos-1)+locs(i)-21;
            end
        end
        %figure(1);hold on;plot(locs,-pks/3,'*');
        %drawnow;
        if(length(locs)<2)
            continue;
        end
        last_step = sample_gyro(locs(end-1):locs(end),:);
        last_step_accel = sample_accel(locs(end-1):locs(end),:);
        last_step_boundary = [locs(end-1)+length(accel_data)-500,locs(end)+length(accel_data)-500];
        
        if(time_stamp_step~=0)
            time_stamp_step = ts_2(last_step_boundary(2));
        else
            continue;
        end
        %find leg length
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%attention
        if(step_count<1000)
            %leg_length_mean = 1.1;
        else
            g = accel_esense_list(3,:);
            %mean_g = conv(g,ones(1000,1))/1000;
            %mean_g = mean_g(500:end-500);
            mean_g = mean(g);
            g=g-mean_g;
            intg_accel = cumsum(g*9.8*1/30);
            v_mean = conv(intg_accel,ones(200,1))/200;
            v_mean = v_mean(100:end-100);
            v = intg_accel-v_mean;
            disp_v = cumsum(v/30);
            disp_mean = conv(disp_v, ones(200,1))/200;
            disp_mean = disp_mean(100:end-100);
            disp_v = disp_v - disp_mean;
            for i_step = 1:step_count-1
                displace(i_step) = max(disp_v(locs_esense(i_step):locs_esense(i_step+1)))-min(disp_v(locs_esense(i_step):locs_esense(i_step+1)));
            end
            displace = displace(displace<0.1);
            displace = displace(displace>0.02);
            displace = displace(floor(end*0.1):floor(end*0.9));
            valid_turn_angle = turn_angle(find(turn_angle<median(turn_angle)+std(turn_angle)));
            valid_turn_angle = valid_turn_angle(find(valid_turn_angle>median(turn_angle)-std(turn_angle)));
            leg_length_mean_old = leg_length_mean;
            leg_length_mean = mean(displace)/(1-cos(mean(valid_turn_angle)/180*pi));
            ratio_length = leg_length_mean/leg_length_mean_old;
            curser_list = curser_list*ratio_length;
            clf(4);
            figure(4);
            plot(curser_list(:,1),curser_list(:,2),'*');
            xlim([-10,10]);
            ylim([-10,10]);
        end
        
        if(last_step_boundary_old(2)<last_step_boundary(1)+20)%&&locs_esense(end)/0.3+40>=locs(end-1))
            %new step found
            step_count = step_count+1;
            step{step_count} = last_step;
            time_stamp_step_list(step_count) = time_stamp_step;
            
            find_walking_direction_stream;
            tracking_total_stream;
            
        end
        last_step_boundary_old = [locs(end-1)+length(accel_data)-500,locs(end)+length(accel_data)-500];
        locs = locs+length(accel_data)-500;
        abs_loc = curser;
    end

end
