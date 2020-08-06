addpath('tts');
hint_text = {'This is an emergency button'};
hint_ado=tts(hint_text, ...
    'Microsoft Zira Desktop - English (United States)',0,44100);
AAR_loc_list = zeros(3,4,4);
AAR_obj_list = cell(3,4);
loc_left_top = [4.6, 2.7, 1.2;...
    ];
last_seg_idx = length(hint_ado)-1024;

for obj_idx =1:size(loc_left_top,1)
    
    AAR_loc = loc_left_top;
    AAR_loc(1) = AAR_loc(1)+(col-1)*1;
    AAR_loc(3) = AAR_loc(3)-(row-1)*0.8;
    AAR_loc_list(row,col,:) = AAR_loc;
    obj = struct();
    obj.loc = AAR_loc(1:3);
    obj.audio = hint_ado;
    obj.last_seg_idx = last_seg_idx;
    AAR_obj_list{row,col} = obj;
end
save('head/data/0911_eval_list','AAR_loc_list','AAR_obj_list');