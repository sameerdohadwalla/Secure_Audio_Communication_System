fs=44100;;  % sampling frequency
duration=7;%time to record
disp("press enter to start recording")
pause;
Fs = 44100 ; 
nBits = 16 ; 
nChannels = 1 ; 
ID = -1; % default audio input device 
recObj = audiorecorder(Fs,nBits,nChannels,ID);
disp("start speaking")
recordblocking(recObj,10);
disp('End of Recording.');
x = getaudiodata(recObj);
y=bandpass(x,[1999 2001],fs);%identify the starting beacon bit
w=bandpass(x,[2999 3001],fs);%identify the trailing beacon bit
t=1:length(x);
plot(t/Fs,y)
%NFFT=length(x)*2
figure;
hold on
plot(t/Fs,abs(x))
m=mean(abs(y));
start_time=max(find((abs(y)>50*m)==1))/Fs%identify start time from filtered signal
end_time=min(find((abs(w)>50*m)==1))/Fs%identify end time from filtered signal
scatter(start_time,max(abs(y)))
scatter(end_time,max(abs(w)))
hold off;
%% 
%############################################applying filter banks#######################################################
m=mean(abs(y))
start_sample=max(find((abs(y)>20*m)==1))%get start sample
start_time=max(find((abs(y)>20*m)==1))/Fs
hfreq=[1209,1336,1477,1633];
lfreq=[697,770,852,941];
window_freqs=[];
winlength=0.25;
for i=start_sample:winlength*Fs:end_time*Fs-winlength
    try
%applying filters to check for all DTMF frequencies
y1209=bandpass(x(i:i+winlength*Fs),[1208 1210],fs);
y1336=bandpass(x(i:i+winlength*Fs),[1335 1337],fs);
y1477=bandpass(x(i:i+winlength*Fs),[1477 1479],fs);
y1633=bandpass(x(i:i+winlength*Fs),[1632 1634],fs);
y697=bandpass(x(i:i+winlength*Fs),[696 698],fs);
y770=bandpass(x(i:i+winlength*Fs),[769 771],fs);
y852=bandpass(x(i:i+winlength*Fs),[851 853],fs);
y941=bandpass(x(i:i+winlength*Fs),[940 942],fs);
%determining which frequencies were present
[M,Ih]=max([mean(abs(y1209)) mean(abs(y1336)) mean(abs(y1477)) mean(abs(y1633))]);
[M,Il]=max([mean(abs(y697)) mean(abs(y770)) mean(abs(y852)) mean(abs(y941))]);
window_freqs=[window_freqs;hfreq(Ih),lfreq(Il)];
    end
end
disp("frequencies detected\n")
window_freqs
disp("filtering done")
%% 
%############################################Decrypting message####################################################### 
key=input("enter decryption key\n");
hfreq=[1209,1336,1477,1633];
rng(key)
hfreq=hfreq(randperm(length(hfreq)));
lfreq=[697,770,852,941];
lfreq=lfreq(randperm(length(lfreq)));
hexnos=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];
freqs=[hfreq(1),lfreq(1);hfreq(1),lfreq(2);hfreq(1),lfreq(3);hfreq(1),lfreq(4);hfreq(2),lfreq(1);hfreq(2),lfreq(2);hfreq(2),lfreq(3);hfreq(2),lfreq(4);hfreq(3),lfreq(1);hfreq(3),lfreq(2);hfreq(3),lfreq(3);hfreq(3),lfreq(4);hfreq(4),lfreq(1);hfreq(4),lfreq(2);hfreq(4),lfreq(3);hfreq(4),lfreq(4)];
freqs;
hexMessage="";
for i =1:length(window_freqs)
%hexnos(find(sum(window_freqs(i,:)==freqs,2)==2))
hexMessage=hexMessage+hexnos(find(sum(window_freqs(i,:)==freqs,2)==2));
if mod(i,2)==0
    hexMessage=hexMessage+" ";
end
end
hexMessage=split(hexMessage);
number = hex2dec(hexMessage);
convertCharsToStrings(native2unicode(number,'utf-8')')
