function realtime_receiver_demo(mode)
%xcorr_val = zeros(1,length(data));
%for i = 1:length(data)-t_end*48000
%    xcorr_val(i)=downchirp*data(i:i+t_end*48000);
%end
recorder1 = audiorecorder(48000, 24, 1);
%recorder1 = audiorecorder;
global t
t = tcpip('127.0.0.1',10086);

% Open socket and wait before sending data
fopen(t);
%fwrite(t,1);
% bpFilt2 = designfilt('bandpassfir','FilterOrder',30, ...
%          'CutoffFrequency1', 4000,'CutoffFrequency2',8000, ...
%          'SampleRate',48000);

close all;
%count = 50;
%codeVec = [];
figure(5);
while (1)
     virtualBeacon = uicontrol('Style','pushbutton','String','VirtualBeaconActive','Callback',@pushButton_callback);
     recordblocking(recorder1,0.2);
     data = getaudiodata(recorder1);
     if mode == 1
         snr = measureSNR(data, 0.2);
         if snr > 50
             code = 1;
             disp('Real Beacon Detected');
             fwrite(t, code);
         else
             code = 0;
         end
     else
        if decodeTone(data) == '7'
            code = 1;
            disp('Real Beacon Detected');
            fwrite(t,code);
        else
            code = 0;
        end
     end
     %codeVec = [codeVec; code];
     %count = count -1;
end
%disp(tabulate(codeVec));

% while(count > 0)
%     
%     recordblocking(recorder1,0.2);
%     data = getaudiodata(recorder1);
%     code = decodeTone(data);
%     disp(char(code));
%     codeVec = [codeVec; code];
%     %figure; spectrogram(data, 1024, 512, 48000, 48000)
% %     for i = 1:(length(slice)-1)
% %         code = decodeTone(data(slice(i):slice(i+1)));
% %         disp(char(code));
% %         codeVec = [codeVec; code];
% %     end
%     count = count-1;
%     %pause(2);
% end
% disp(tabulate(codeVec));

 %fft_data = abs(fft(data));
%  beacon_1 = sum(fft_data(f_1*0.45:f_1*0.55))
%  beacon_2 = sum(fft_data(f_2*0.45:f_2*0.55))
%  beacon_1 = sum(fft_data(f_1*0.5-1:f_1*0.5+1));
%  beacon_2 = sum(fft_data(f_2*0.5-1:f_2*0.5+1));
 %plot(fft_data);
%  if(beacon_1>mean(fft_data)+std(fft_data)*2&&beacon_1>10)
%      DataToSend=1;
%      count = count+1;
%      beep;
%      fwrite(t,DataToSend);
%  end
%  if(beacon_2>mean(fft_data)+std(fft_data)*2&&beacon_2>10)
%      DataToSend=2;
%      fwrite(t,DataToSend);
%  end
 
fclose(t);
delete(t);
end

function virtualBeaconActive()
    global t
    fwrite(t, 2);
end
function pushButton_callback(hObject, eventdata, handles)
    virtualBeaconActive();
    display("Detect Virtual Beacon");
    close(gcf);
end
