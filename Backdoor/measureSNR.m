function snr = measureSNR(data,duration)
    %% Align the signal
    %duration = 0.2;
    t = 0:1/48000:duration;
    signal = chirp(t, 4000, duration, 1000);
    corr = xcorr(data, signal);
    figure; plot(corr);
    % Compute SNR with cross-correlation
    peak = max(abs(corr));
    Ps = peak^2;
    Pn = (sum(corr.^2)-Ps)/(length(corr)-length(data)+length(signal));
    snr = 10*log(Ps/Pn);
%  Compute SNR in frequency domain
%     [m, peak_id] = max(corr);
%     seg = data(peak_id-length(data):peak_id-length(data)+length(signal));
%     
%     fft_seg = abs(fft(seg,48000));
%     
%     figure; plot(fft_seg);
%     s_power = sum(fft_seg(3000:4000).^2)/1000;
%     n_power = (sum(fft_seg.^2)-2*s_power)/(length(fft_seg)-2);
%     snr = 10*log(s_power/n_power);
end
