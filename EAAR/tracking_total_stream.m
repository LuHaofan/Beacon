turn_angle = turn_angle_1;
%leg_length_mean = 1;
%step_scale = leg_length_mean/leg_length_old;
step_length =leg_length_mean * 2 * sin(turn_angle/180*pi);
%%%%%%%%%%%%%%%%%%%%%%%%%
if(step_length>0.1)
    %%%%%%%%%%%%%%%%%%%%%%%%%
    orientation_list_final = [orientation_list_final,orientation_1,orientation_2];
    figure(4);
    if(length(curser_list)==0)
        ori_initial = orientation_1;
        clf(4);
        curser_list = [0,0];
    end
    % if(length(curser_list)==6)
    %     if(std(orientation_list_final)<0.2)
    %         ori_bias = -mean(orientation_list_final-ori_initial);
    %     elseif(std(orientation_list_final(1:4))<0.2)
    %         ori_bias = -mean(orientation_list_final(1:5)-ori_initial);
    %     elseif(std(orientation_list_final(3:6))<0.2)
    %         ori_bias = -mean(orientation_list_final(3:6)-ori_initial);
    %     else
    %         errordlg('Please reset')
    %     end
    %
    %     curser_list = curser_list*[cos(ori_bias),-sin(ori_bias);sin(ori_bias),cos(ori_bias)];
    % end
    curser_1 = curser_list(end,:)+[sin(orientation_1-ori_initial+ori_bias),cos(orientation_1-ori_initial+ori_bias)]*step_length;
    curser = curser_1+[sin(orientation_2-ori_initial+ori_bias),cos(orientation_2-ori_initial+ori_bias)]*step_length;   
    % clf(4);
    % hold on;
    % plot(obj_loc(1),obj_loc(2),'^');
    figure(4);
    curser_list = [curser_list;curser_1;curser];
    plot(curser_list(:,1),curser_list(:,2),'-*');
            hold on;
        plot(curser_list(end,1),curser_list(end,2),'-^');
        hold off;
    %plot(curser_list(end,1),curser_list(end,2),'*');
    leg_length_old = leg_length_mean;
    
    xlim([-10,10]);
    ylim([-3,25]);
else
    time_stamp_step_list(end) = [];
end