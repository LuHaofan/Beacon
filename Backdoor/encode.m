function encode(code)
    warning off;
    genericFileNameCommand = 'genericAttack_command_temp.wav';
    genericFileNameBackdoor = 'genericAttack_backdoor_temp.wav';
    if(1)
        disp('Info: Deleteing old files.');
        delete(genericFileNameCommand);
        delete(genericFileNameBackdoor);
    end
    
    %% Generate Chirp signal and normalize
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
    y = cat(2, s0, s1);
    y = cat(2, y, s2);
    secCarr = chirp(t,0,duration,0);
    y2 = cat(2, secCarr, secCarr);
    y2 = cat(2, y2, secCarr);
    y = y./max(y);
    y2 = y2./max(y2);
    %% Create BackDoor Signal
    disp('Info: Creating BackDoor signal');
    fs = 96000;
    nbits = 24;
    carrFreq = 40000;
    secCarrFreq = carrFreq;

    inSpData = y;
    spFs = 48000;
        %upConvData = upConversion(inSpData, spFs, fs, carrFreq);
    upConvData = upConversion_SSBSC(inSpData, spFs, fs, carrFreq);

    tt = (0:length(upConvData)-1)'*(1/fs);
    secCarr = real(exp(2*pi*-1j*secCarrFreq*tt));


    upConvData = upConvData ./ max(abs(upConvData));
    secCarr = secCarr ./ max(abs(secCarr));
        
        
    inSpData = y2;
    spFs = 48000;
        %upConvData = upConversion(inSpData, spFs, fs, carrFreq);
    upConvData2 = upConversion_SSBSC(inSpData, spFs, fs, carrFreq);
            
    upConvData2 = upConvData2 ./ max(abs(upConvData2));
    secCarr = secCarr ./ max(abs(secCarr));
    
    y1 = upConvData(:); 
    y2 = upConvData2(:);
    y1 = y1./max(abs(y1));
    y2 = y2./max(abs(y2));

    y = [y1,y2];

    audiowrite(genericFileNameBackdoor,y,fs,'BitsPerSample',nbits);
    
    %% Play backdoor signal
    [y, fs] = audioread(genericFileNameBackdoor);
    timeOfPlay = size(y,1)/fs;
    figure; spectrogram(y(:,1), 1024, 512, fs, fs);
    figure; spectrogram(y(:,2), 1024, 512, fs, fs);
    sound(y, fs);
    disp('Playing BackDoor sound...');
    pause(timeOfPlay+1);
    disp('Done!');
end


function upConvData = upConversion_SSBSC(inSpData, spFs, fs, carrFreq)
    upSamplingFactor = fs/spFs;
    upSampData = interp(inSpData, upSamplingFactor);
    upSampData = hilbert(upSampData);
    
    if(0)
        figure; plot(abs(upSampData));
        figure; spectrogram(upSampData, 1024, 512, fs, fs);
        %sound(upSampData, fs);
    end

    tt = (0:length(upSampData)-1)'*(1/fs);
    upConvData = real(exp(2*pi*1j*carrFreq*tt) .* upSampData');
    upConvData = upConvData ./ max(abs(upConvData));
    
    if(0)
        figure; plot(upConvData);
        figure; spectrogram(upConvData, 1024, 512, fs, fs);
    end
end
