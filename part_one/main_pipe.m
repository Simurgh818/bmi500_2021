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

dbPath = 'C:\Users\sinad\OneDrive - Georgia Institute of Technology\BMI 500 Bio Informatics\wk12\dataset\deidentified_trc\';
% file = "C:\Users\sinad\OneDrive - Georgia Institute of Technology\BMI 500 Bio Informatics\wk12\dataset\deidentified_trc\273\sit-point1-TP.trc";

% Initialize variable:
outcomes.max_p={} ; outcomes.f_max_p = {}; outcomes.f_sd = {}; 
outcomes.rms_power={}; outcomes.record_id={};outcomes.icd = {};

% impord icd
csv_path = 'C:\Users\sinad\OneDrive - Georgia Institute of Technology\BMI 500 Bio Informatics\wk12\bmi500_2021\icd.csv';
colToRead = {'id','icd'};
opts = detectImportOptions(csv_path);
opts.SelectedVariableNames = colToRead;
icd = readtable(csv_path, opts);

% trc = rename_trc(read_trc(file));
% % Read the column for L.Wrist x, y, z coordinates
% raw_data = trc{:,startsWith(names(trc),"L.Wrist")};
% 
% % 1- filter the data
% filtered_data = preprocess_marker_data(raw_data, trc.Time, [2, 45]);
% 
% 
% % 2- Singular value decomposition - return primary component
% pc1_mm = pc1(filtered_data);
% % disp(size(pc1_mm))
% 
% % 3- tremor analysis
% % ToDo: loop through subdirectories and records
% fName = file;
% markerName = "L.Wrist";
% [p, f, t ] = tremor_analysis('fName',fName, 'markerName',markerName);
% 
% % power analysis
% 
% % max power
% p_max = max(p(:,2:end),[], 2);
% 
% % frequency at overall max power (Hz)
% [outcomes.max_p(1,1), idx] = max(p_max);
% outcomes.f_max_p(1,1) = idx/100;
% 
% % variability in peak frequency 
% [pks, locs] = findpeaks(p_max);
% outcomes.f_sd(1,1) = std(pks);
% 
% % average RMS power (mm) within +/- 0.5 Hz of freq at overall max power
% try
%     outcomes.rms_power(1,1) = rms(p_max(round(idx - 50): round(idx + 50)));
% catch
%     if (idx-50)<0
%         outcomes.rms_power(1,1) = NaN;
%     end
% end

% outcomes = [max_p, f_max_p, f_sd, rms_power];
% disp(outcomes)

dirNames = dir(fullfile(dbPath));
folderNames = dirNames([dirNames(:).isdir]);
folderNames = folderNames(~ismember({folderNames(:).name},{'.','..'}));

[numPatients, ~] = size(folderNames);
% try

for fn=1:numPatients
    fprintf('Currently Processing subject: %s \n', folderNames(fn,:).name);
    recordNames = dir(fullfile(dbPath, folderNames(fn,:).name,'*.trc'));
    
    outcomes.record_id{fn,1} = folderNames(fn,:).name;
    if folderNames(fn,:).name == icd.id(fn,1)
        outcomes.icd{fn,1} = icd.icd(fn,1);
    end
    [numRecords, ~] = size(recordNames);
    for rn=1:numRecords
        
        fprintf('Currently Processing record #: %s \n', recordNames(rn,:).name);
%             [~, baseFileName, extension] = fileparts(recordNames(rn, :).name);
%             pathSplit = split(dbPath, '\');
        inPath = fullfile(dbPath,folderNames(fn,:).name,  recordNames(rn,:).name);
        
%           Preprocessing

        trc = rename_trc(read_trc(inPath));
        % Read the column for L.Wrist x, y, z coordinates
        raw_data = trc{:,startsWith(names(trc),"L.Wrist")};
        
        if isempty(raw_data)
            break
        end

        % 1- filter the data
        filtered_data = preprocess_marker_data(raw_data, trc.Time, [2, 45]);
        
        
        % 2- Singular value decomposition - return primary component
        pc1_mm = pc1(filtered_data);
        % disp(size(pc1_mm))
        
        % 3- tremor analysis
   
        markerName = "L.Wrist";
        [p, f, t ] = tremor_analysis('fName',inPath, 'markerName',markerName);
        
        % power analysis
        
        % max power
        outcomes.p_max{rn, 1} = max(p(:,2:end),[], 2);
        
        % frequency at overall max power (Hz)
        [max_p, idx] = max(outcomes.p_max{rn, 1});
        outcomes.f_max_p{rn, 1} = idx/100;
        
        % variability in peak frequency 
        [pks, locs] = findpeaks(outcomes.p_max{rn, 1});
        outcomes.f_sd{rn, 1} = std(pks);
        
        % average RMS power (mm) within +/- 0.5 Hz of freq at overall max power
        try
            outcomes.rms_power{rn, 1} = rms(p_max(round(idx - 50): round(idx + 50)));
        catch
            if (idx-50)<0
                outcomes.rms_power{rn, 1} = NaN;
            end
        end
            
    end
end

% catch
%     if isempty(folderNames)
%         fprintf('Dataset did not load properly. Please check the path.');
%     end
% 
% end
%% plots

% % plot the first few seconds
% time_s = trc.Time;
% 
% figure(1);
% plot(time_s, pc1_mm);
% xlim([0 5]);
% xlabel('seconds')
% ylabel('mm')
% 
% % 3D visualization
% figure(2)
% waterfall(f, seconds(t), p')
% xlabel('Freq (Hz)');
% ylabel('Time (s)')
% wtf = gca;
% view([30 45]);
% 
% % differen visualization of power
% figure(3)
% hold on
% for i=size(p,2)
%     plot(f, p(:, i));
% end
% xlabel('Hz')
% ylabel('mm^2/Hz')
% hold off

% histogram percent of population vs. freq peaks

%% Summarize outcomes for the left wrist resting-action tremor

% store all subjects' outcomes in a CSV

%             figPath = fullfile(results_path, folderNames(fn,:).name);
%             if ~exist(figPath, 'dir')
%                 mkdir(figPath)
%             end