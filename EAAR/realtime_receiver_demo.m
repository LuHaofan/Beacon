function realtime_receiver_demo(f_1,f_2)
%xcorr_val = zeros(1,length(data));
%for i = 1:length(data)-t_end*48000
%    xcorr_val(i)=downchirp*data(i:i+t_end*48000);
%end
%recorder1 = audiorecorder(48000,16,1,2);
recorder1 = audiorecorder;
t = tcpip('127.0.0.1',10086);

% Open socket and wait before sending data
%fopen(t);



count = 0;
while(1)
 recordblocking(recorder1,0.5);
 
 data = getaudiodata(recorder1);
 fft_data = abs(fft(data));
 %beacon_1 = sum(fft_data(f_1*0.45:f_1*0.55))
 %beacon_2 = sum(fft_data(f_2*0.45:f_2*0.55))
 beacon_1 = sum(fft_data(f_1*0.5-1:f_1*0.5+1));
 beacon_2 = sum(fft_data(f_2*0.5-1:f_2*0.5+1));
 plot(fft_data);
 if(beacon_1>mean(fft_data)+std(fft_data)*2&&beacon_1>10)
     DataToSend=1;
     count = count+1;
     beep;
     fwrite(t,DataToSend);
 end
 if(beacon_2>mean(fft_data)+std(fft_data)*2&&beacon_2>10)
     DataToSend=2;
     fwrite(t,DataToSend);
 end
 
end
fclose(t);
delete(t);
end

