% If we want to delete all the .txt and .mat files that we've just created
% with the script. We need to close MATLAB first, then open it and run this script.

close all
clear all

for iSub = [86 87 89:98] % change 2 to the number of folders you want to remove the files from

dirs.data = 'P:\3017048.01\data';
dirs.sub = fullfile(dirs.data,sprintf('sub-%.3d',iSub),'ses-intake','EOG');
cd (dirs.sub);
delete_mat = strcat(dirs.sub, '\', sprintf('EOG_test%d_processed.mat',iSub));
delete_v_txt = strcat(dirs.sub, '\', sprintf('vEOGdata%d.txt',iSub));
delete_h_txt = strcat(dirs.sub, '\', sprintf('hEOGdata%d.txt',iSub));

delete (delete_mat)
delete (delete_v_txt)
delete (delete_h_txt)
end
disp ('Success!')

% Laura Barreiro