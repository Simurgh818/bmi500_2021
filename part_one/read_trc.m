function data = read_trc(file)
% function data = read_trc(file)
%
% Read a *.trc file into a table
% 
% usage
% supply full path to .trc file
% returns table of marker data

% Read the data from the .trc file
data = readtable(file, "FileType", "Text", "VariableNamingRule", "Preserve", "VariableNamesLine", 4, "NumHeaderLines", 6);
% only keep the first 182 columns
data = data(:,1:182);
end

