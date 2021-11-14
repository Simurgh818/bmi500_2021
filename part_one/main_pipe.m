%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tremor analysis pipeline: a biomarker to distinguise parkinson's disease
% from Essential Tremor disease
% 
% 1. The time vector needs to be passed to the preprocess_marker_data 
% (data, time, cutoffs) function in order to be able to express the cutoff 
% frequencies in Hz. Matlab uses a normalized frequency description in which 
% frequencies vary between 0 and 1, where 1 is the Nyquist rate, 0.5*the
% sample frequency. % The data are sampled at continuous rate, so the delta
% t can be taken from % anywhere in the time vector.
% 
% 2. All of the outcomes requested can be created by identifying maximum
% values within the power spectrum matrix p returned by pspectrum(). 
% 
% 3. The filtering can be performed with filtfilt() and the butter() methods.
% These are very simple filtering routines with well-behaved pass bands.
% 
% 4. Each of the functions can be completed in 10-20 lines of code or so;
% if you find yourself doing anything more complex than that perhaps
% reconsider your strategy and contact me.

% Syntax:
% 
% 
% Inputs:
% 
% 
% Output:
% 
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2021  Sina Dabiri
% sdabiri@emory.edu
% 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version.
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dataset is in BMI cluster location: /labs/colab/BMI500-Fall2021/deidentified_trc/
% To run Matlab on cluster: matlab -nodesktop -nojvm
clear; 
close all;

file = "C:\Users\sinad\OneDrive - Georgia Institute of Technology\BMI 500 Bio Informatics\wk12\dataset\669\sit-rest1-TP.trc";
trc = rename_trc(read_trc(file));
% Read the column for L.Wrist x, y, z coordinates
raw_data = trc{:,startsWith(names(trc),"L.Wrist")};

% 1- filter the data
filtered_data = preprocess_marker_data(raw_data, trc.Time, [2, 45]);


% 2- Singular value decomposition - return primary component
pc1_mm = pc1(filtered_data);
% disp(size(pc1_mm))

% 3- tremor analysis
% ToDo: loop through subdirectories and records
fName = file;
markerName = "L.Wrist";
[p, f, t ] = tremor_analysis('fName',fName, 'markerName',markerName);

%% plots

% plot the first few seconds
time_s = trc.Time;

figure(1);
plot(time_s, pc1_mm);
xlim([0 5]);
xlabel('seconds')
ylabel('mm')

% 3D visualization
figure(2)
waterfall(f, seconds(t), p')
xlabel('Freq (Hz)');
ylabel('Time (s)')
wtf = gca;
view([30 45]);

% histogram percent of population vs. freq peaks
%% Summarize outcomes for the left wrist resting-action tremor

% max power in any window (mm2/Hz)

% freq at overall max power (Hz)

% variability in peak frequency, Hz

% average RMS power (mm) within +/- 0.5 Hz of frequency at overall max
% power

% outcomes = [max_p, f_max_p, f_sd, rms_power]

% store all subjects' outcomes in a CSV
