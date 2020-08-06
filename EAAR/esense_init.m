load 'ReferenceHRTF.mat' hrtfData sourcePosition;
hrtfData = permute(double(hrtfData),[2,3,1]);
sourcePosition = sourcePosition(:,[1,2]);



%% AAR system options
multi_obj = 1; % 1: source separation, 0: one object at a time
retrieve_cal = 1; 

%% initialization
A = 100;
% load audio/ sound effect
[hint_ado, ~] = audioread('head/data/hint.wav');
[cal_ado, ~] = audioread('head/data/cal.wav');
[cal_done_ado, ~] = audioread('head/data/cal_done.wav');
[idc_ado, fs] = audioread('head/data/human_hint_long.wav');
sys_eval_gnd = [0,0];
load('head/data/0913_dead_reckoning');
%load('head/data/wally_home_test');
%{
load('head/data/0911_eval_list');
row = randi(3); col = randi(4);
sys_eval_gnd = [row,col];
AAR_obj = AAR_obj_list{row,col};
AAR_loc = squeeze(AAR_loc_list(row,col,:))';
%}
[obj_ado, ~] = audioread('head/data/obj.wav');

obj_seg = 1024; % update Binaural impulse in 1024 sample period
idc_last_idx = length(idc_ado)-obj_seg;
deviceWriter = audioDeviceWriter('SampleRate',fs);

%% Binaural init
leftFilter = dsp.FIRFilter('NumeratorSource','Input port');
rightFilter = dsp.FIRFilter('NumeratorSource','Input port');

globalAz = 0;
globalEl = 0;
desiredPosition = [globalAz globalEl];

interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition);

leftIR = squeeze(interpolatedIR(:,1,:))';
rightIR = squeeze(interpolatedIR(:,2,:))';
t = tcpip('0.0.0.0', 12348, 'NetworkRole', 'server');
fopen(t);
disp('Esense connected');

%bias_gyro = [-0.8097; 3.3636; -0.0514];
%bias_gyro = [-0.2350;    2.0841;    0.5018]; %esense0035
bias_gyro = [-0.8213; 3.2981; 0.0010]; %esense 0814
bias_accel = [0.0253; -0.0086; 0.0233];
R_total_es = [1,0,0;0,1,0;0,0,1];

init_ptr = true;
cnt = 1;
print_time = 0;
total_time = 0;
pkt_cnt = 0;
prev_seq = 0;
esense_fs = 30;
%% Annotate variable
annotate_status = 0;
annotate_time = 0;
ann_obj_vec = [0;0;0;];
H = 1.62; % eye height
AAR_range = 9; % m
active_range = 9;
active_Az_range = 30; % degree
active_El_range = 20; % degree
recObj = audiorecorder(44100,16,1,1);
look_down_vec = [0,-1,0];
ROI_obj = [];
tic; 
%obj_loc = [-3,5];