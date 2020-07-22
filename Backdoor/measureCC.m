function cc = measureCC(duration,f_start,bandwidth,f_2, active_channel, filt)
if f_start+bandwidth > 40000
    cc = nan;
    return;
end
recObj = audiorecorder(48000, 24, 1);
disp('Start Recording');
record(recObj);
disp('Playing Backdoor signal');
if f_start+bandwidth > 24000
    sender_demo(1, 1, duration, 40000-f_start,bandwidth,f_2,active_channel);
else
    t = 0:1/96000:duration;
    sig = chirp(t, f_start, duration, f_start+bandwidth);
    %figure; spectrogram(sig, 1024, 512, 96000, 96000);
    sound(sig, 96000);
end
pause(2);
disp('Stop Recording');
stop(recObj);

data = getaudiodata(recObj);
%% Filter the data
if (filt)
    bpFilt2 = designfilt('bandpassfir','FilterOrder',30, ...
         'CutoffFrequency1', 1000,'CutoffFrequency2',8000, ...
         'SampleRate',48000);
    data = filter(bpFilt2, data);
end
figure; spectrogram(data, 1024, 512, 48000, 48000);
%% Configure the expected signal from cross-correlation
if f_start+bandwidth > 24000
    if f_start > 24000 && bandwidth == 0
        t = 0:1/48000:duration;
        signal = chirp(t, 40000-f_start, duration, 40000-f_start);
    elseif f_start >= 24000 && bandwidth > 0
        t = 0:1/48000:duration;
        signal = chirp(t, 40000-f_start, duration, 40000-f_start-bandwidth);
    elseif f_start < 24000 && bandwidth > 0
        t2 = 0:1/48000:duration*(f_start+bandwidth-24000)/bandwidth;
        signal2 = chirp(t2, 40000-24000, duration*(f_start+bandwidth-24000)/bandwidth, 40000-f_start-bandwidth);
        t1 = 0:1/48000:duration*(24000-f_start)/bandwidth;
        signal1 = chirp(t1, f_start, duration*(24000-f_start)/bandwidth, 24000);
        signal = cat(2, signal1, signal2);
    end 
else
    t = 0:1/48000:duration;
    signal = chirp(t, f_start, duration, f_start+bandwidth);
end

%figure; spectrogram(signal, 1024, 512, 48000, 48000);
cc = xcorr(data,signal);
figure; plot(cc);
end