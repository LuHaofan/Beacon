
function code = decodeTone(data)
    spc_diff = 6;
    F1 = [2100, 2400, 2700, 3000];
    F2 = [4350, 4650, 4950, 5250];

    Fs = 48000;
    N = length(data);
    zpad = 8*N;
    f_samples = -Fs/2:Fs/zpad:Fs/2;
    fft_data = abs(dft(data, length(f_samples)));
    fft_data = fft_data./max(fft_data);
    %figure;plot(f_samples, fft_data);
    ind_lower = [0 0 0 0];
    ind_higher = [0 0 0 0];
    for i = (1:4)
        [tmp ind_lower(i)] = min(abs(f_samples-F1(i)));
        [tmp ind_higher(i)] = min(abs(f_samples-F2(i)));
    end
    amp_lo = [0 0 0 0];
    amp_hi = [0 0 0 0];
    for i = (1:4)
        amp_lo(i) = fft_data(ind_lower(i));
        amp_hi(i) = fft_data(ind_higher(i));
    end

    [f1_amp f1] = max(amp_lo);
    [f2_amp f2] = max(amp_hi);
    if abs(f1_amp-f2_amp)<spc_diff
        code_t = freq2num(f1,f2);
    else
        code_t = 'x';
    end
    %% Validation
    F1_v = F1-1000;
    F2_v = F2-1000;
    ind_lo_v = [0 0 0 0];
    ind_hi_v = [0 0 0 0];
    for i = 1:4
        [tmp ind_lo_v(i)] = min(abs(f_samples-F1_v(i)));
        [tmp ind_hi_v(i)] = min(abs(f_samples-F2_v(i)));
    end
    amp_lo_v = [0 0 0 0];
    amp_hi_v = [0 0 0 0];
    for i = (1:4)
        amp_lo_v(i) = fft_data(ind_lo_v(i));
        amp_hi_v(i) = fft_data(ind_hi_v(i));
    end

    [f1_amp_v f1_v] = max(amp_lo_v);
    [f2_amp_v f2_v] = max(amp_hi_v);
    if abs(f1_amp_v-f2_amp_v)<spc_diff
        code_v = freq2num(f1_v,f2_v);
    else
        code_v = 'y';
    end
    if code_t == code_v
        code = code_t;
    else
        code = 'x';
    end
end

function dft_data = dft(data, len)
    dft_data = fftshift(fft(data, len));
end

function num = freq2num(f1, f2)
    if f1 == 1 && f2 == 1
        num = '1';
    elseif f1 == 1 && f2 == 2
        num = '2';
    elseif f1 == 1 && f2 == 3
        num = '3';
    elseif f1 == 2 && f2 == 1
        num = '4';
    elseif f1 == 2 && f2 == 2
        num = '5';
    elseif f1 == 2 && f2 == 3
        num = '6';
    elseif f1 == 3 && f2 == 1
        num = '7';
    elseif f1 == 3 && f2 == 2
        num = '8';
    elseif f1 == 3 && f2 == 3
        num = '9';
    elseif f1 == 4 && f2 == 1
        num = '0';
    elseif f1 == 4 && f2 == 2
        num = '*';
    elseif f1 == 4 && f2 == 3
        num = '#';
    elseif f1 == 1 && f2 == 4
        num = 'A';
    elseif f1 == 2 && f2 == 4
        num = 'B';
    elseif f1 == 3 && f2 == 4
        num = 'C';
    elseif f1 == 4 && f2 == 4
        num = 'D';
    else
        num = 'x';
    end
end









