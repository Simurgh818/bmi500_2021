function [p, f, t] = tremor_analysis(varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% input parsing
default_fName = "C:\Users\sinad\OneDrive - Georgia Institute of Technology\BMI 500 Bio Informatics\wk12\dataset\669\sit-rest1-TP.trc";
default_markerName = "L.Wrist";
default_plot_flag = 0;

pars = inputParser;
pars.addOptional('fName', default_fName);
pars.addOptional('markerName',default_markerName);
pars.addOptional('plot_flag', default_plot_flag);
pars.parse(varargin{:});

% assign arguments
fName = pars.Results.fName;
markerName = pars.Results.markerName;
plot_flag = pars.Results.plot_flag;

% read file
trc = rename_trc(read_trc(fName));
raw_data = trc{:, startsWith(names(trc),markerName)};
filtered_data = preprocess_marker_data(raw_data, trc.Time,[2 45]);

% calcluate the primary component
pc1_mm = pc1(filtered_data);

time_s = trc.Time;
TT = timetable(seconds(time_s), pc1_mm);
TT.Properties.VariableNames = [markerName];
TT.Properties.VariableUnits = ["mm"];

% power spectrum analysis
[p, f, t ] = pspectrum(TT, 'spectrogram', 'MinThreshold', -50,...
    'FrequencyResolution', 0.5, 'FrequencyLimits', [0 20]);
end