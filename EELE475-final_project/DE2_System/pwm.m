
clock = 50;  % in MHz
clock_period = 1/(clock * 10^6);  

%-----------------------------
% Neutral Control word
%-----------------------------
value = 1.5;  % msec
value1 = (value/1000) * clock * 10^6;  % clock cycles
signedness = 0;  % 0=unsigned, 1=signed
word_length = 24;  % number of bits
fraction_length = 0;  % number of bits in fraction
w = fi(value1, signedness, word_length, fraction_length);
disp(['PWM neutral settings = ' num2str(value) ' msec'])
disp(['Decimal:  ' num2str(w.dec)])
disp(['Binary:   ' num2str(w.bin)])
disp(['Hex:      ' num2str(w.hex)])
disp(['Number of bits in word = ' num2str(word_length)])
disp(' ')


%-----------------------------
% Smallest Control word
%-----------------------------
value = 1.0;  % msec
value1 = (value/1000) * clock * 10^6;  % clock cycles
signedness = 0;  % 0=unsigned, 1=signed
word_length = 24;  % number of bits
fraction_length = 0;  % number of bits in fraction
w = fi(value1, signedness, word_length, fraction_length);
disp(['PWM smallest settings = ' num2str(value) ' msec'])
disp(['Decimal:  ' num2str(w.dec)])
disp(['Binary:   ' num2str(w.bin)])
disp(['Hex:      ' num2str(w.hex)])
disp(['Number of bits in word = ' num2str(word_length)])
disp(' ')

%-----------------------------
% Largest Control word
%-----------------------------
value = 2.0;  % msec
value1 = (value/1000) * clock * 10^6;  % clock cycles
signedness = 0;  % 0=unsigned, 1=signed
word_length = 24;  % number of bits
fraction_length = 0;  % number of bits in fraction
w = fi(value1, signedness, word_length, fraction_length);
disp(['PWM largest settings = ' num2str(value) ' msec'])
disp(['Decimal:  ' num2str(w.dec)])
disp(['Binary:   ' num2str(w.bin)])
disp(['Hex:      ' num2str(w.hex)])
disp(['Number of bits in word = ' num2str(word_length)])
disp(' ')

%-----------------------------
% Pulse period
%-----------------------------
value = 20;  % msec
value1 = (value/1000) * clock * 10^6;  % clock cycles
signedness = 0;  % 0=unsigned, 1=signed
word_length = 24;  % number of bits
fraction_length = 0;  % number of bits in fraction
w = fi(value1, signedness, word_length, fraction_length);
disp(['PWM Pulse period = ' num2str(value) ' msec'])
disp(['Decimal:  ' num2str(w.dec)])
disp(['Binary:   ' num2str(w.bin)])
disp(['Hex:      ' num2str(w.hex)])
disp(['Number of bits in word = ' num2str(word_length)])
disp(' ')

%-----------------------------
% control word
%-----------------------------
value1 = 100;  % msec
signedness = 1;  % 0=unsigned, 1=signed
word_length = 8;  % number of bits
fraction_length = 0;  % number of bits in fraction
w = fi(value1, signedness, word_length, fraction_length);
disp(['control word = ' num2str(value)])
disp(['Decimal:  ' num2str(w.dec)])
disp(['Binary:   ' num2str(w.bin)])
disp(['Hex:      ' num2str(w.hex)])
disp(['Number of bits in word = ' num2str(word_length)])
disp(' ')



