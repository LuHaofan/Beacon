
function code = decodeTone(data)
    F1 = [3000, 3300, 3600, 3900];
    F2 = [4800, 5100, 5400, 5700];
    Fs = 48000;
    N = length(data);
    zpad = 8*N;
    f_samples = -Fs/2:Fs/zpad:Fs/2;
    fft_data = abs(dft(data, zpad));
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
    [tmp f1] = max(amp_lo);
    [tmp f2] = max(amp_hi);
    code = freq2num(f1,f2);
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
    else
        num = 'D';
    end
end









