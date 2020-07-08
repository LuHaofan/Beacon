%sender_demo(1, 1, 0.1, 5000, 0, 0);
function sender_demo(resetOld, repeatCount,t_end,f_1,f_2,active_channel)
  
    
  
    
    genericFileNameCommand = 'genericAttack_command_temp.wav';
    genericFileNameBackdoor = 'genericAttack_backdoor_temp.wav';
    if(resetOld == 1)
        disp('Info: Deleteing old files.');
        delete(genericFileNameCommand);
        delete(genericFileNameBackdoor);
    end
    
   % y=tts(inCommand,'Microsoft Zira Desktop - English (United States)',0,48000);
   t = 0:1/48000:t_end;
    y = chirp(t,f_1,t_end,f_1); 
    %y = [downchirp,y];
    y2 = chirp(t,f_2,t_end,f_2);
    y = y./max(y);
    y2 = y2./max(y2);
    
   
    
        disp('Info: Creating BackDoor signal');
        %%%%%%%%%%%%%%% Create BackDoor Signal %%%%%%%%%%%%%%%%%%%%%%
        fs = 96000;
        %fs = 192000;
        nbits = 24;
        carrFreq = 30000;
        secCarrFreq = carrFreq;

        inSpData = y;
        spFs = 48000;
        %upConvData = upConversion(inSpData, spFs, fs, carrFreq);
        upConvData = upConversion_SSBSC(inSpData, spFs, fs, carrFreq);

        tt = (0:length(upConvData)-1)'*(1/fs);
        secCarr = real(exp(2*pi*-1j*secCarrFreq*tt));
        %figure; spectrogram(secCarr, 1024, 512, fs, fs);
        
        
        upConvData = upConvData ./ max(abs(upConvData));
        secCarr = secCarr ./ max(abs(secCarr));
        
        
        inSpData = y2;
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
        y1 = upConvData(:)+ secCarr(:);
        y2 = upConvData2(:)+ secCarr(:);
        y1 = y1./max(abs(y1));
        y2 = y2./max(abs(y2));
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
    if(repeatCount>1)
        y = repmat(y, repeatCount, 1);
    end
    figure; spectrogram(y(:,1), 1024, 512, fs, fs)
    timeOfPlay = size(y,1)/fs;
    sound(y, fs);
    disp('Playing BackDoor sound...');
    pause(timeOfPlay+1);
    disp('Done!');
end



function upConvData = upConversion(inSpData, spFs, fs, carrFreq)
    upSamplingFactor = fs/spFs;
    upSampData = interp(inSpData, upSamplingFactor);

    if(1)
        figure; plot(upSampData);
        figure; spectrogram(upSampData, 1024, 512, fs, fs);
        %sound(upSampData, fs);
    end

    tt = (0:length(upSampData)-1)'*(1/fs);
    upConvData = real(exp(2*pi*1j*carrFreq*tt) .* upSampData);
    
    if(1)
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