function send_tone(repeatCount,duration,f_1,f_2,active_channel)
    warning off;
    genericFileNameCommand = 'genericAttack_command_temp.wav';
    genericFileNameBackdoor = 'genericAttack_backdoor_temp.wav';
    if(1)
        disp('Info: Deleteing old files.');
        delete(genericFileNameCommand);
        delete(genericFileNameBackdoor);
    end
    %% Generate Chirp signal and normalize
   % y=tts(inCommand,'Microsoft Zira Desktop - English (United States)',0,48000);
   %t_end = 0.2;
    t = 0:1/48000:duration;
    y1 = chirp(t, f_1, duration, f_1);
    y2 = chirp(t, f_2, duration, f_2);
    y = y1+y2;
    carr = 40000;
    y_c = chirp(t,40000-carr,duration,40000-carr);
    y = y./max(y);
    y_c = y_c./max(y_c);
    
   
    
        disp('Info: Creating BackDoor signal');
        %%%%%%%%%%%%%%% Create BackDoor Signal %%%%%%%%%%%%%%%%%%%%%%
        fs = 96000;
        %fs = 192000;
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
        
        
        inSpData = y_c;
        spFs = 48000;
        %upConvData = upConversion(inSpData, spFs, fs, carrFreq);
        upConvData2 = upConversion_SSBSC(inSpData, spFs, fs, carrFreq);
            
        upConvData2 = upConvData2 ./ max(abs(upConvData2));
        secCarr = secCarr ./ max(abs(secCarr));
        
%         upConvData = upConvData + secCarr;
%         secCarr = upConvData;
%         upConvData = upConvData ./ max(abs(upConvData));
%         secCarr = secCarr ./ max(abs(secCarr));
        
        %figure; plot(upConvData); hold on; plot(secCarr);
        
        %%%%%%%%%%%for testing combine two channels%%%%%%%%%%%
        y1 = upConvData(:); %+ secCarr(:);
        y2 = upConvData2(:);%+ secCarr(:);
        y1 = y1./max(abs(y1));
        y2 = y2./max(abs(y2));
%         bpFilt = designfilt('bandpassfir','FilterOrder',30, ...
%          'CutoffFrequency1',40000-f_1-500,'CutoffFrequency2',40000-f_1+bandwidth+500, ...
%          'SampleRate',fs);
%         y1 = filter(bpFilt, y1);
        if(active_channel == 1)
            y = [y1, zeros(length(y1),1)];
        elseif(active_channel == 2)
            y = [zeros(length(y2),1), y2];
        else
            y = [y1,y2];
        end
        %y = [y; zeros(48000*t_end,2)];

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%original%%%%%%%%%%%%%%%%
        %y = [upConvData(:) secCarr(:)];
        %y = [y; zeros(48000*t_end,2)];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        audiowrite(genericFileNameBackdoor,y,fs,'BitsPerSample',nbits);
  %  end


    
    %%%%%%%%%%%%%%% Play BackDoor Signal %%%%%%%%%%%%%%%%%%%%%%
    [y, fs] = audioread(genericFileNameBackdoor);
    %y =  cat(1, y, zeros(0.1*fs,2));
    if(repeatCount>1)
        y = repmat(y, repeatCount, 1);
    end
    timeOfPlay = size(y,1)/fs;
    %figure; spectrogram(y(:,1), 1024, 512, fs, fs);
    %figure; spectrogram(y(:,2), 1024, 512, fs, fs);
    sound(y, fs);
    disp('Playing BackDoor sound...');
    pause(timeOfPlay+1);
    disp('Done!');
end



function upConvData = upConversion(inSpData, spFs, fs, carrFreq)
    upSamplingFactor = fs/spFs;
    upSampData = interp(inSpData, upSamplingFactor);

    if(0)
        figure; plot(upSampData);
        figure; spectrogram(upSampData, 1024, 512, fs, fs);
        %sound(upSampData, fs);
    end

    tt = (0:length(upSampData)-1)'*(1/fs);
    upConvData = real(exp(2*pi*1j*carrFreq*tt) .* upSampData);
    
    if(0)
        figure; plot(upConvData);
        figure; spectrogram(upConvData, 1024, 512, fs, fs);
    end
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