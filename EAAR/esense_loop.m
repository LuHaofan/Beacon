if t.BytesAvailable
    pkt_cnt = pkt_cnt+1;
    data_list = fread(t, t.BytesAvailable);
    L = length(data_list);
    ptr = 1;
    while ptr<L
        %% Hot fix....
        if ptr+15>512
            break;
        end
        if data_list(ptr) == 85 %% IMU data
            data_es = data_list(ptr:ptr+15);
            ptr = ptr+16;
            seq = data_es(2);
            raw_gyro = data_es(5:10);
            gyro = typecast(uint8(raw_gyro), 'int16');
            gyro = double(swapbytes(gyro))/65.5;
            gyro = gyro - bias_gyro;
            raw_accel = data_es(11:16);
            accel = typecast(uint8(raw_accel), 'int16');
            accel = double(swapbytes(accel))/8192;
            accel = accel - bias_accel;
            if init_ptr % require init
                uncalib_x = accel(1);
                uncalib_y = accel(2);
                uncalib_z = accel(3);
                R_initial_es = vrrotvec2mat([-uncalib_y,uncalib_x,0,-atan2(sqrt(uncalib_x^2+uncalib_y^2),uncalib_z)]);
                init_ptr = 0;
                R_total_es = [1,0,0;0,1,0;0,0,1];
                prev_seq = seq - 1;
            end
            interval = seq - prev_seq;
            if interval < -128
                interval = interval + 256;
            end
            interval = interval *1/esense_fs;
            sample = R_initial_es*gyro/180*pi;
            sample_accel = (R_initial_es*accel);
            sample = R_total_es*sample;
            sample_accel = R_total_es*sample_accel;
            accel_esense_list = [accel_esense_list, sample_accel];
            R_total_es_list = [R_total_es_list, R_total_es];
            mag = norm(sample);
            sample = sample/mag;
            theta = mag*interval;
            quat(2)=sin(theta/2)*sample(1);
            quat(3)=sin(theta/2)*sample(2);
            quat(4)=sin(theta/2)*sample(3);
            quat(1)=cos(theta/2);
            R = quat2rotm(quat);
            R_total_es =R*R_total_es;
            prev_seq = seq;
            if (annotate_status ==1 || annotate_status == 4) && total_time - annotate_time > 4
                
                annotate_time = total_time;
                [Az, El] = R2AzEl(R_total_es, look_down_vec);
                ann_gnd_angle = El;
                
                disp(['GND_Angle:',num2str(ann_gnd_angle)]);
                ann_obj_D = H*cotd(ann_gnd_angle);
                disp(['Dist:',num2str(ann_obj_D)]);
                if ann_obj_D>5 % Max annotate dist
                    ann_obj_D = 5;
                elseif ann_obj_D<0
                    annotate_status = 0; % Invalid object, DO NOT ADD
                end
                if annotate_status == 4
                    % User is gazing at an object, start retrieval calibration
                    annotate_status = 0;
                    cur_obj = ROI_obj(1);
                    retrieve_cal_loc = [cur_obj.loc(1)-ann_obj_D*sind(Az),...
                        cur_obj.loc(2)-ann_obj_D*cosd(Az)];
                    calib_pt_list = [calib_pt_list;retrieve_cal_loc];
                    calibrated_pt_id = length(calib_pt_list);
                    flag_calib = 1;
                    clear_ROI_all;
                    cal_time_list = [cal_time_list; total_time];
                else
                    annotate_status = 2;
                    record(recObj, 5);
                end
            elseif annotate_status ==2 && total_time - annotate_time > 5
                annotate_status = 0;
                y = getaudiodata(recObj);
                obj_loc = [abs_loc(1)+ann_obj_D*sind(ann_obj_Az), abs_loc(2) ...
                    + ann_obj_D*cosd(ann_obj_Az),  H-ann_obj_D*tand(ann_obj_angle)];
                AAR_loc = [AAR_loc; [obj_loc,0]]; % Last entry as active indicator
                ann_obj = struct('loc',obj_loc,'audio',y,'last_seg_idx',length(y)-obj_seg);
                AAR_obj = [AAR_obj; ann_obj];
            elseif annotate_status == 3 && total_time - annotate_time > 5
                % calibration done
                flag_calib = 1;
                calibrated_pt_id = -1;
                init_ptr = true;
                annotate_status = 0;
                sound(cal_done_ado,fs);
            elseif annotate_status == 5 && total_time - annotate_time > 3
                annotate_status = 0;
            end
        elseif ~annotate_status
            %% REPLACE ANNOTATION FUNC. TO GND COLLECTION
            % button pressed,
            if retrieve_cal && ~isempty(ROI_obj) ...
                    && ROI_obj(1).active == 1
                annotate_status = 4;
                cur_obj = ROI_obj(1);
                sound(hint_ado, fs);
            else
                annotate_status = 5;
%                 sound(5*obj_ado, fs);
%                 disp('SAMPLE COLLECTED');
%                 disp('SAMPLE COLLECTED');
%                 gnd_time_list = [gnd_time_list; total_time];
%                 gnd_soft_list = [gnd_soft_list; curser];
            end
            ptr = ptr+4;
            
            annotate_time = total_time;
            [Az, El] = R2AzEl(R_total_es, look_down_vec);
            ann_obj_angle = El;
            ann_obj_Az = Az;
            
        elseif annotate_status ==5 && total_time - annotate_time > 0.5
            % button pressed again after 0.5 second, calibration
            annotate_status = 3;
            annotate_time = total_time;
            ptr = ptr+4;
            clear sound;
            sound(cal_ado,fs);
        elseif annotate_status ==4 && total_time - annotate_time > 0.5
            % tap twice when obj active, delete
            annotate_status = 5;
            % return to 0 after 1 second, avoid double tapping
            annotate_time = total_time;
            ptr = ptr+4;
            clear sound;
            clear_ROI_all;
            AAR_loc(cur_obj.ptr,:)=[];
            AAR_obj(cur_obj.ptr)=[];
        else % button press but already annotating, skip this packet
            ptr = ptr+4;
        end
        
    end
    [Az, El] = R2AzEl(R_total_es, look_down_vec);
    if total_time>print_time+1
        disp('Az/El');
        disp([num2str(Az),'/',num2str(El)]);
        print_time = total_time;
        pkt_cnt = 0;
        % Check if the first object near user, if yes, add to active list
        if multi_obj == 1
            MAX_OBJ = size(AAR_loc,1);
        else
            MAX_OBJ = min(1,size(AAR_loc,1));
        end
        for i=1:MAX_OBJ
            if AAR_loc(i,4)==0 && pdist2(abs_loc,AAR_loc(i,1:2)) < AAR_range
                AAR_loc(i,4) = 1;
                obj = AAR_obj(i);
                obj = init_AAR_obj(obj,i);
                ROI_obj = [ROI_obj; obj];
            end
        end
    end
    %% update FIR filter for every object in range
    i=1;
    while i<=length(ROI_obj)
        obj = ROI_obj(i);
        if pdist2(abs_loc,obj.loc(1:2)) > AAR_range
            % object out of range, remove from ROI list
            AAR_loc(obj.ptr,4) = 0;
            ROI_obj(i)=[];
            continue;
        end
        obj_vec = obj.loc(1:2)-abs_loc;
        D = vecnorm(obj_vec);
        globalAz = atan2d(obj_vec(1),obj_vec(2));
        globalEl = atan2d(H-obj.loc(3),D);
        
        ROI_obj(i).A = 100/vecnorm(obj_vec);
        desiredAz =  wrapTo360(round(Az-globalAz));
        desiredEl = wrapTo180(round(El-globalEl));
        if desiredEl > 90
            desiredEl = 90;
        elseif desiredEl < -90
            desiredEl = -90;
        end
        desiredPosition = [desiredAz desiredEl];
        interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition);
        ROI_obj(i).LIR = squeeze(interpolatedIR(:,1,:))';
        ROI_obj(i).RIR = squeeze(interpolatedIR(:,2,:))';
        if obj.active == 1
            % object in LoS
            if D>active_range || abs(wrapTo180(globalAz-Az))>10 || abs(globalEl-El)>20
                %leave LoS
                ROI_obj(i).active = 0;
                ROI_obj(i).aptr = 1;
                ROI_obj(i).iptr = 1;
            end
        elseif obj.active == 0 && D<active_range && abs(wrapTo180(globalAz-Az))<10 && abs(globalEl-El)<20
            % User staring at the object
            % Put this object to the first of the queue
            % Mark as active
            obj = ROI_obj(i);
            ROI_obj(i) = ROI_obj(1);
            ROI_obj(1) = obj;
            ROI_obj(1).active = 1; % initial
        end
        
        
        if ROI_obj(1).active == 1
            break; % If any obj is active, no need to track other positions
        end
        i = i+1;
    end
end
if ~isempty(ROI_obj) && annotate_status==0
    if  ROI_obj(1).active == 1
        obj = ROI_obj(1);
        if obj.aptr <= obj.last_seg_idx
            audio_range = obj.aptr:(obj.aptr+obj_seg-1);
            ROI_obj(1).aptr = ROI_obj(1).aptr + obj_seg;
        else
            audio_range = [obj.aptr:length(obj.audio),1:obj_seg];
            audio_range = audio_range(1:obj_seg);
            ROI_obj(1).aptr = audio_range(end)+1;
        end
        audio = obj.audio(audio_range);
        %disp(sys_eval_gnd);
        LCh = ROI_obj(1).LF(obj.A*audio,obj.LIR);
        RCh = ROI_obj(1).RF(obj.A*audio,obj.RIR);
        deviceWriter([LCh,RCh]);
    else
        LCh = zeros(obj_seg,1);
        RCh = zeros(obj_seg,1);
        for i=1:length(ROI_obj)
            obj = ROI_obj(i);
            if obj.iptr <= idc_last_idx
                audio_range = obj.iptr:(obj.iptr+obj_seg-1);
                ROI_obj(i).iptr = ROI_obj(i).iptr + obj_seg;
            else
                audio_range = [obj.iptr:length(idc_ado),1:obj_seg];
                audio_range = audio_range(1:obj_seg);
                ROI_obj(i).iptr = audio_range(end)+1;
            end
            audio = idc_ado(audio_range);
            LCh = LCh + ROI_obj(i).LF(obj.A*audio,obj.LIR);
            RCh = RCh + ROI_obj(i).RF(obj.A*audio,obj.RIR);
        end
        deviceWriter([LCh,RCh]);
    end
end

