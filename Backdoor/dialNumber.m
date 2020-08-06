function dialNumber(num, duration)
    [f1 f2] = num2Freq(num);
    send_tone(1, duration, f1, f2, 0);
end

function [f1, f2] = num2Freq(number)
    F1 = [697, 770, 852, 941];
    F2 = [1209, 1336, 1477, 1633];
    keySet = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '*', '#',...
        'A', 'B', 'C','D'};
    valueSet = {[0,0], ...  %1
        [0,1], ...          %2 
        [0,2], ...          %3
        [1,0], ...          %4
        [1,1], ...          %5
        [1,2], ...          %6
        [2,0], ...          %7
        [2,1], ...          %8
        [2,2], ...          %9
        [3,0], ...          %0
        [3,1], ...          %*
        [3,2], ...          %#
        [0,3], ...          %A
        [1,3], ...          %B
        [2,3], ...          %C
        [3,3]};             %D
    map = containers.Map(keySet, valueSet);
    pair = map(number);
    f1 = F1(pair(1)+1);
    f2 = F2(pair(2)+1);
end