%% Binaural part
load 'ReferenceHRTF.mat' hrtfData sourcePosition;
hrtfData = permute(double(hrtfData),[2,3,1]);
sourcePosition = sourcePosition(:,[1,2]);

A = 100;
% load audio
fileReader = dsp.AudioFileReader('long_speech.m4a');
deviceWriter = audioDeviceWriter('SampleRate',fileReader.SampleRate);
ear_fs = fileReader.SampleRate;
ear_seg = fileReader.SamplesPerFrame;

leftFilter = dsp.FIRFilter('NumeratorSource','Input port');
rightFilter = dsp.FIRFilter('NumeratorSource','Input port');

globalAz = 0;
desiredAz = globalAz;
globalEl = 0;
desiredEl = globalEl;
desiredPosition = [desiredAz desiredEl];

interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition, ...
    "Algorithm","VBAP");

leftIR = squeeze(interpolatedIR(:,1,:))';
rightIR = squeeze(interpolatedIR(:,2,:))';
t = tcpip('0.0.0.0', 12348, 'NetworkRole', 'server');
%t = udp('127.0.0.1','LocalPort',12348);
fopen(t);
disp('Connected');

bias_gyro = [-0.8097; 3.3636; -0.0514];
bias_accel = [0.0253; -0.0086; 0.0233];
R_total = [1,0,0;0,1,0;0,0,1];
init_ptr = true;
head_vec = [1;0;0;];
cnt = 1;
print_time = 0;
total_time = 0;
pkt_cnt = 0;
prev_seq = 0;
esense_fs = 30;
while ~isDone(fileReader)
    if t.BytesAvailable
        if ~init_ptr
            total_time = total_time+toc;
        end
        tic;
        pkt_cnt = pkt_cnt+1;
        data = fread(t, t.BytesAvailable);
        data_list = reshape(data, 16,[]);
        
        for i=1:size(data_list,2)
            data = data_list(:,i);
            seq = data(2);
            raw_gyro = data(5:10);
            gyro = typecast(uint8(raw_gyro), 'int16');
            gyro = double(swapbytes(gyro))/65.5;
            gyro = gyro - bias_gyro;
            raw_accel = data(11:16);
            accel = typecast(uint8(raw_accel), 'int16');
            accel = double(swapbytes(accel))/8192;
            accel = accel - bias_accel;
            if init_ptr % require init
                uncalib_x = accel(1);
                uncalib_y = accel(2);
                uncalib_z = accel(3);
                R_initial = vrrotvec2mat([-uncalib_y,uncalib_x,0,pi-atan(sqrt(uncalib_x^2+uncalib_y^2)/(uncalib_z))]);
                init_ptr = 0;
                prev_seq = seq - 1;
            end
            interval = seq - prev_seq;
            if interval < -128
                interval = interval + 256;
            end
            interval = interval *1/esense_fs;
            sample = R_initial*gyro/180*pi;
            sample = R_total*sample;
            mag = norm(sample);
            sample = sample/mag;
            theta = mag*interval;
            quat(2)=sin(theta/2)*sample(1);
            quat(3)=sin(theta/2)*sample(2);
            quat(4)=sin(theta/2)*sample(3);
            quat(1)=cos(theta/2);
            R = quat2rotm(quat);
            R_total =R*R_total;
            prev_seq = seq;
        end
        %% update FIR filter
        if total_time>print_time+1
            disp('Az/El');
            disp([wrapTo360(atan2d(-R_total(2,1),R_total(1,1))), wrapTo180(atan2d(-R_total(3,1), vecnorm(R_total(1:2,1))))]);
            disp(pkt_cnt);
            print_time = total_time;
            pkt_cnt = 0;
        end
        desiredAz =  wrapTo360(round(globalAz-atan2d(R_total(2,1),R_total(1,1))));
        desiredEl = wrapTo180(round(globalEl+atan2d(R_total(3,1), vecnorm(R_total(1:2,1)))));
        desiredPosition = [desiredAz desiredEl];
        
        interpolatedIR  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition);
        
        leftIR = squeeze(interpolatedIR(:,1,:))';
        rightIR = squeeze(interpolatedIR(:,2,:))';
    end
    if init_ptr
        continue;
    end
    audioIn = fileReader();
    
    leftChannel = leftFilter(A*audioIn(:,1),leftIR);
    rightChannel = rightFilter(A*audioIn(:,1),rightIR);
    
    deviceWriter([leftChannel,rightChannel]);
    
end
fclose(t);
release(deviceWriter);
release(fileReader);