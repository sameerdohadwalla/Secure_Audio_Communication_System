amp=10

key=input("enter encryption key\n")%defining encryotion key to be 5

fs=44100;;% sampling frequency

duration=0.25;%duration of each pulse

values=0:1/fs:duration;%time axis

message=input("Enter message to be sent\n",'s')%message to be sent

decString = unicode2native(message,'utf-8');%converting message to unicode

hexString = dec2hex(decString);%converting unicode to a hex number

hfreq=[1209,1336,1477,1633];%defining higher frequency values for DTMF

rng(key)%setting random seed to the encryption key

hfreq=hfreq(randperm(length(hfreq)));%encrypting by shuffling order of higher frequencies

lfreq=[697,770,852,941];%defining higher frequency values for DTMFm

lfreq=lfreq(randperm(length(lfreq)));%encrypting by shuffling order of lower frequencies

hexnos=['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'];

freqs=[hfreq(1),lfreq(1);hfreq(1),lfreq(2);hfreq(1),lfreq(3);hfreq(1),lfreq(4);hfreq(2),lfreq(1);hfreq(2),lfreq(2);hfreq(2),lfreq(3);hfreq(2),lfreq(4);hfreq(3),lfreq(1);hfreq(3),lfreq(2);hfreq(3),lfreq(3);hfreq(3),lfreq(4);hfreq(4),lfreq(1);hfreq(4),lfreq(2);hfreq(4),lfreq(3);hfreq(4),lfreq(4)];

beacon=0:1/fs:0.2;%defining time duration of beacon bit to be sent before and after message

soundarr=[amp*sin(2*pi*2000*beacon)];%generating sine wave for leading beacon bit

for i=1:length(hexString)
    tones1=freqs(find(hexnos==hexString(i,1)),:);%finding frequency for a particular hex number
    tones2=freqs(find(hexnos==hexString(i,2)),:);
    a1=amp*sin(2*pi*tones1(1)*values)+2*amp*sin(2*pi*tones1(2)*values);
    a2=amp*sin(2*pi*tones2(1)*values)+2*amp*sin(2*pi*tones2(2)*values);
    soundarr=[soundarr a1 a2];%appending different DTMF frequency sine waves to the array
    % we have 1 unicode character represented by 2 hex numbers sent
    % consecutively
end

disp("done")
soundarr=[soundarr amp*sin(2*pi*3000*beacon)];%appending trailing beacon bit
sound(soundarr,fs)%play sound