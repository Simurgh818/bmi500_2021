function [filtered_data] = preprocess_marker_data(raw_data,trc_time, range)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% number of samples per second

% fs = find(trc_time==1)-find(trc_time==0);
fs=1/(trc_time(2)-trc_time(1));
fc= range;

% normalized frequency
w0 = fc/(fs/2);

[b, a] = butter(6,w0);

filtered_data = filter(b, a, raw_data);

end