function code_t = decodeTone3(data, duration)
    F1 = [2100, 2400, 2700, 3000];
    F2 = [4350, 4650, 4950, 5250];
    %%%%%%%%%%%% Conventional DTMF %%%%%%%%%%%%%%
    Fs = 48000;
    N = length(data);
    zpad = 16*N;
    f_samples = -Fs/2:Fs/zpad:Fs/2;
    fft_data = abs(dft(data, length(f_samples)));
    %fft_data = fft_data./max(fft_data);
    %figure;plot(f_samples, fft_data);
    ind_lower = [0 0 0 0];
    ind_higher = [0 0 0 0];
    for i = (1:4)
        [tmp ind_lower(i)] = min(abs(f_samples-F1(i)));
        [tmp ind_higher(i)] = min(abs(f_samples-F2(i)));
    end
    [tmp idx_dtd] = min(abs(f_samples-dare_to_die));
    amp_lo = [0 0 0 0];
    amp_hi = [0 0 0 0];
    for i = (1:4)
        amp_lo(i) = fft_data(ind_lower(i));
        amp_hi(i) = fft_data(ind_higher(i));
    end
    amp_lo = [amp_lo fft_data(idx_dtd)];
    amp_hi = [amp_hi fft_data(idx_dtd)];
%     disp(amp_lo);
%     disp(amp_hi);
    [tmp f1] = max(amp_lo);
    [tmp f2] = max(amp_hi);
    
    %%%%%%% verifyTone %%%%%%%%%%%%
    f1_idx = f1;
    f2_idx = f2+4;
    f1_range = get_f_range(f1_idx);
    f2_range = get_f_range(f2_idx);
    if verifyTone(F1(f1), f1_range, f_samples, fft_data)
        idx1 = f1_idx;
    else
        idx1 = -1;
    end
    if verifyTone(F2(f2),f2_range, f_samples, fft_data)
        idx2 = f2;
    else
        idx = -1;
    end
    if idx1 == -1 || idx2 == -1
        disp('Not detected');
    else
        f_range3 = get_f_range(8+idx2*4+idx1);
        if verifyTone(F2(f2)-F1(f1), f_range3, f_samples, fft_data)
            code_t = freq2num(idx1,idx2);
            disp('Detect', code_t);
        else
            disp('Not detected');
        end
    end
end

function f_range = get_f_range(f_idx)
    F1 = [2100, 2400, 2700, 3000];
    F2 = [4350, 4650, 4950, 5250];
    F1F2 = zeros(1,16);
    for i = 1:4
        for j = 1:4
            F1F2((i-1)*4+j) = F2(i)-F1(j);
        end
    end
    fVec = [F1, F2, F1F2];
    lut = zeros(length(fVec),2);
    for i = 1:length(fVec)
        lut(i,1) = fVec(i)-50;
        lut(i,2) = fVec(i)+50;
    end
    f_range = lut(f_idx,:);
end
function dft_data = dft(data, len)
    dft_data = fftshift(fft(data, len));
end

function bo = verifyTone(f, f_range, f_ZP, X_ZP)
    LB = find(round(f_ZP) == f_range(1));
    RB = find(round(f_ZP) == f_range(2));
    APX = find(round(f_ZP) == f);
    [M,T_idx] = max(X_ZP(LB(1):RB(1)));
    T_idx = T_idx+LB(1);
    bo = false;
    for i = 1:length(APX)
        if T_idx == APX(i)
            bo = true;
        end
    end
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
