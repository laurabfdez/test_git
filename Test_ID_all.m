%% Call processEOG
close all
clear all

if isunix
   dirs.home= '\project\3017048.01';
    % add fieldtrip.
    addpath /home/common/matlab/fieldtrip;
elseif ispc
    dirs.home='P:\3017048.01';
%     dirs.home           = 'M:';    
      % add fieldtrip.
    addpath H:\common\matlab\fieldtrip; % LB doesn't add subfolders, genpath? or just fileio
    addpath H:\common\matlab\fieldtrip\fileio;
else
    keyboard;    
end

dirs.data=fullfile(dirs.home,'data'); % JM replces dirs.log. 
dirs.code=fullfile(dirs.home,'code','analysis','eog');
dirs.rawDir=fullfile(dirs.home,'raw');

addpath(dirs.code)  
addpath(dirs.data)

addpath(genpath(fullfile(dirs.code,'EBR_analysis_scripts_HSlagter')));

% get subject dir when BrainVision data.
% get subject directories.
subNo=length(dir(fullfile(dirs.data,'sub-*')));

[num, raw]=xlsread(fullfile(dirs.rawDir,'Volumes.2016-2646.xlsx'));
viciIDs = num(2:end,1); scrIDs=num(2:end,2); % LB first row is general info

counter = 0; % LB added counter so we know how many participants are analyzed

% LB start loop here:
for iSub = [2]
    % LB subject 008 is not a participant but a pilot (changed files,
    % solved with the new loop)
    % LB 016 different location of EOG data (now it skips this subject)
    % LB 017 not working (maybe mismatch sID and vID?
    % LB 024 has two .eeg files
    % LB 025 different location (now it skips this subject)
    % LB 028 not working
    % LB 039 different location of EOG data (now it skips this subject)
    % LB 045 not working
    % LB 051 not working (README) is something similar happening with 024?
    % (solved with the new loop)
    % LB 054 different location of EOG data
    % LB 058 different location of EOG data (now it skips this subject)
    % LB 064 different location of EOG data (now it skips this subject)
    % LB 066 no EOG folder (now it skips this subject)
    % LB 068 has two .eeg files (solved with the new loop)
    % LB 085 different location of EOG data (now it skips this subject)
    % LB 088 different location of EOG data (now it skips this subject)
% FOR ALL THE REST OF THE SCRIPT
%("end" should be the last word in this script)

vID = sprintf ('%.3d', viciIDs(iSub)); % with 00 before %just changed that
sID = sprintf ('%.3d', scrIDs(iSub)); % with 00 before.

% if we use Ruben's script for conversion
% add the script to path first (outside loop)
% dirs.conversion=fullfile(dirs.home,'code','analysis','mri','preprocessing');
% addpath(dirs.conversion);
% and check line 45, different path to Volumes
% settings.io.rawDir = dirs.rawDir;
% Now inside the loop
% vID = iSub;
% sID = subjectID_conversion('VICI_ID',iSub,'SCR_ID',settings);
% vID = sprintf ('%.3d', vID) % with 00 before;
% sID = sprintf ('%.3d', sID) % with 00 before;
% and we can delete scrIDs and viciIDs variables, as well as the Volumes
% doc
% BUT displays warning message :( Warning: Variable names were modified to make them valid MATLAB identifiers. 

    
% get subject specific directory.
    dirs.subRaw        = fullfile(dirs.data,sprintf('sub-%.3d',iSub),'ses-intake','EOG');
if  isempty (ls(dirs.subRaw)) == 0 % LB so if there is no EOG folder in ses-intake, it will skip this subject
    cd (dirs.subRaw);
    dirs.fileArray      = dir('*.eeg');
    
maindir = fullfile(dirs.code,'EBR_analysis_scripts_HSlagter');
writeDir = fullfile(dirs.data,'derivatives','eog'); % LB changed it (where do you want to save the data?)
subject = strcat ('EOG_test',num2str(iSub));
%********************************
% LB added exceptions
if vID == '008'
    path_to_folder = 'P:\3017048.01\data\sub-008\ses-intake\EOG';
    path_to_name = 'jesmaa_scr005.eeg';
    
elseif vID == '024'
    path_to_folder = 'P:\3017048.01\data\sub-024\ses-intake\EOG';
    path_to_name = 'jesmaa_eog_SCR097.eeg';
   
elseif vID == '068'
    path_to_folder = 'P:\3017048.01\data\sub-068\ses-intake\EOG';
    path_to_name = 'jesmaa_eog_SCR069_1.eeg';
    
elseif vID == '051'
    path_to_folder = 'P:\3017048.01\data\sub-051\ses-intake\EOG';
    path_to_name = 'jesmaa_scr006.eeg';
    
else
    path_to_folder = dirs.fileArray.folder;
    path_to_name = dirs.fileArray.name;
end

results = ft_read_data (strcat(path_to_folder, '\', path_to_name));

results_v = results (1, :);
results_h = results (2, :);

fid = fopen (sprintf('vEOGdata%d.txt',iSub), 'w');
fprintf (fid, '%f ', results_v);

fid = fopen (sprintf('hEOGdata%d.txt',iSub), 'w');
fprintf (fid, '%f ', results_h);

EBR_filename = strcat(path_to_folder, '\', sprintf('vEOGdata%d.txt',iSub));

% LB to get the sampling rate
cd (dirs.subRaw);
% dirs.fileInfo = dir('*.vhdr'); % LB you can also read it from the .eeg file, so that you don't need an extra loop
information = ft_read_header (strcat(path_to_folder, '\', path_to_name));
sampling_rate = information.Fs;

cd P:\3017048.01\code\analysis\eog\EBR_toolbox

processEOG_sEBR('text',sampling_rate,EBR_filename) %512 = sampling rate. JM: We have 100Hz. DP:Probably acq instead of text since we give eog channel.
% LB added sampling_rate

%the "EBR" structure is an assignment of the global EOG variable to the base
%workspace (see hack in exitEOG). This allows to save the final data used
%for processing in the graphical interface for future reference 
%(thresholds, exact peak times, etc.).

dataTime = length(EBR.signal)/EBR.sampRate; % time of data collected
sEBRpermin = length(EBR.t_peaks)/dataTime*60; % spontaneous eye blink rate, in minutes^-1
fprintf('Spontaneous eye blink rate for subject %s: %f eye blinks per minute\n.', subject, sEBRpermin); % print the sEBR to the command window
counter = counter + 1;
%% Save result
sEBRfile = fullfile(writeDir, [subject '_processed' '.mat']); % name of the file to save
if exist(sEBRfile, 'file') % if there already is a file with that name
posResp = 'Yes!';
    negResp = 'Dear god, no';
    writeAns = questdlg('Data file already exists! Are you sure you want to overwrite it? If not, modify the file name and try again.', 'File already exists', posResp, negResp, negResp); % show a prompt
    switch writeAns
        case negResp % if you say no, do nothing: modify the file name above
        case posResp % if you say yes, save over it
       save(sEBRfile, 'EBR', 'sEBRpermin'); %save the processed data: the EBR structure, sEBR and the blink IC number
    end
else
save(sEBRfile, 'EBR', 'sEBRpermin');
end
else
    fprintf('There is no EOG folder for subject %d\n.', iSub);
end
end