function cc = measureCC(f_start, bandwidth,data, duration)
%% Filter the data
bpFilt2 = designfilt('bandpassfir','FilterOrder',30, ...
         'CutoffFrequency1', 1000,'CutoffFrequency2',8000, ...
         'SampleRate',48000);
data = filter(bpFilt2, data);

%figure; spectrogram(data, 1024, 512, 48000, 48000);
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
%figure; plot(cc);
end