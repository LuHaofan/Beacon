%%
data1=tts('Hello, come and look at me', ...
'Microsoft Zira Desktop - English (United States)',0,44100);
data1 = [data1; zeros(44100*3,1);];
audiowrite('head/data/human_hint1.wav',data1,44100);
%%
data2=tts('Great, come closer', ...
'Microsoft Zira Desktop - English (United States)',0,44100);
data2 = [data2; zeros(44100*3,1);];
audiowrite('head/data/human_hint2.wav',data2,44100);
%%
data3=tts('When you look at me, I will tell you who I am', ...
'Microsoft Zira Desktop - English (United States)',0,44100);
data3 = [data3; zeros(44100*3,1);];
audiowrite('head/data/human_hint3.wav',data3,44100);
%%
data = [data1;data2;data3];
audiowrite('head/data/human_hint_long.wav',data,44100);
%%
data=tts('Calibrating. Please stand in the calibration point and look ahead.', ...
'Microsoft Zira Desktop - English (United States)',0,44100);
audiowrite('head/data/cal.wav',data,44100);
%%
data=tts('Calibration done.', ...
'Microsoft Zira Desktop - English (United States)',0,44100);
audiowrite('head/data/cal_done.wav',data,44100);