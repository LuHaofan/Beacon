function re = decode(data, code)
    bpFilt2 = designfilt('bandpassfir','FilterOrder',30, ...
         'CutoffFrequency1', 1000,'CutoffFrequency2',8000, ...
         'SampleRate',48000);
    data = filter(bpFilt2, data);
    duration = 0.07;
    t = 0:1/48000:duration;
    switch code
        case 0
            s0 = chirp(t, 4000, duration, 3000);    % 0
            s1 = chirp(t, 3000, duration, 2000);    % 0
            s2 = chirp(t, 2000, duration, 1000);    % 0
        case 1
            s0 = chirp(t, 3000, duration, 4000);    % 1
            s1 = chirp(t, 3000, duration, 2000);    % 0
            s2 = chirp(t, 2000, duration, 1000);    % 0
        case 2
            s0 = chirp(t, 4000, duration, 3000);    % 0
            s1 = chirp(t, 2000, duration, 3000);    % 1
            s2 = chirp(t, 2000, duration, 1000);    % 0
        case 3
            s0 = chirp(t, 3000, duration, 4000);    % 1
            s1 = chirp(t, 2000, duration, 3000);    % 1
            s2 = chirp(t, 2000, duration, 1000);    % 0
        case 4
            s0 = chirp(t, 4000, duration, 3000);    % 0
            s1 = chirp(t, 3000, duration, 2000);    % 0
            s2 = chirp(t, 1000, duration, 2000);    % 1
        case 5
            s0 = chirp(t, 3000, duration, 4000);    % 1
            s1 = chirp(t, 3000, duration, 2000);    % 0
            s2 = chirp(t, 1000, duration, 2000);    % 1
        case 6
            s0 = chirp(t, 4000, duration, 3000);    % 0
            s1 = chirp(t, 2000, duration, 3000);    % 1
            s2 = chirp(t, 1000, duration, 2000);    % 1
        case 7
            s0 = chirp(t, 3000, duration, 4000);    % 1
            s1 = chirp(t, 2000, duration, 3000);    % 1
            s2 = chirp(t, 1000, duration, 2000);    % 1
    end
    
    signal = cat(2, s0, s1);
    signal = cat(2, signal ,s2);
    corr = xcorr(data, signal);
    [M I] = max(corr);
    if M/mean(corr(I-length(signal):I+length(signal))) > 10
        sig_length = 0.07*48000+1;
        sample_length = 512;
        sample0_s = data(I+sample_length: I+2*sample_length);
        sample0_e = data(I+sig_length-2*sample_length:I+sig_length-sample_length);
        sample1_s = data(I+sig_length+sample_length:I+sig_length+2*sample_length);
        sample1_e = data(I+2*sig_length-2*sample_length:I+2*sig_length-sample_length);
        sample2_s = data(I+2*sig_length+sample_length:I+2*sig_length+2*sample_length);
        sample2_e = data(I+3*sig_length-2*sample_length:I+3*sig_length-sample_length);
        fft0_s = max(abs(fft(sample0_s)));
        fft0_e = max(abs(fft(sample0_e)));
        fft1_s = max(abs(fft(sample1_s)));
        fft1_e = max(abs(fft(sample1_e)));
        fft2_s = max(abs(fft(sample2_s)));
        fft2_e = max(abs(fft(sample2_e)));

        if (fft0_s > fft0_e && fft1_s > fft1_e && fft2_s > fft2_e && code == 0)
            re = true;
        elseif (fft0_s < fft0_e && fft1_s > fft1_e && fft2_s > fft2_e && code == 1)
            re = true;
        elseif (fft0_s > fft0_e && fft1_s < fft1_e && fft2_s > fft2_e && code == 2)
            re = true;
        elseif (fft0_s < fft0_e && fft1_s < fft1_e && fft2_s > fft2_e && code == 3)
            re = true;
        elseif (fft0_s > fft0_e && fft1_s > fft1_e && fft2_s < fft2_e && code == 4)
            re = true;
        elseif (fft0_s < fft0_e && fft1_s > fft1_e && fft2_s < fft2_e && code == 5)
            re = true;
        elseif (fft0_s > fft0_e && fft1_s < fft1_e && fft2_s < fft2_e && code == 6)
            re = true;
        elseif (fft0_s < fft0_e && fft1_s < fft1_e && fft2_s < fft2_e && code == 7)
            re = true;
        end
    end
end

