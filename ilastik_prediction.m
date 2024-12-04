
% run ilastik headless
% ilastik export settings - add saving to a separate folder

% Find any version of Ilastik.exe from user computer
basePath = 'C:\Program Files\';
wildcardPath = dir(fullfile(basePath, 'ilastik*'));
if ~isempty(wildcardPath)
    ilastik_path = fullfile(basePath, wildcardPath(1).name, 'ilastik.exe'); % get full path
else
    error('Ilastik not found among Program Files.');
end

% User chooses images folder, user choose model?
ilastik_proj_path = 'C:\Users\Kasutaja\Desktop\BSc_thesis\testrun\draft1.ilp';
imfolder = 'C:\Users\Kasutaja\Desktop\BSc_thesis\testrun\';
cd(imfolder);

images = dir(fullfile(imfolder,'*.tif'));  % do I exclude TIFF format?
cmds = struct('command', {});

for i = 1:numel(images)
    cmd = sprintf('"%s" --headless --project="%s" "%s"', ...
    ilastik_path, ...
    ilastik_proj_path, ...
    images(i).name);
    cmds(i).command = cmd;
end

logFile = 'process_log.txt';
errorLog = 'error_log.txt';

logs = fopen(logFile, 'a');
errors = fopen(errorLog, 'a');

if logs == -1
    error('Failed to open process_log file.');
end
if errors == -1
    error('Failed to open error_log file.');
end

cleanup = onCleanup(@() fclose('all')); % close all open files when the script ends

% Execute commands, catch errors
try
    for i = 1:numel(cmds)
        fprintf(logs, 'Analyzing image %d/%d: %s', i, numel(cmds), images(i).name);
        status = system(cmds(i).command); % Run command
        
        if status == 0
            fprintf(logs, ' - Success.\n');
            % BUG - ütleb success kui on clear error, A1_bad.tif file on
            % saast
        else
            fprintf(logs, 'Image %d failed with status %d.\n', i, status);
            fprintf(errors, 'Image %d failed: %s\n', i, cmds(i).command);
        end
    end

catch ME
    fprintf(logs, 'Script interrupted with error: %s\n', ME.message);
    fprintf(errors, 'Script interrupted with error: %s\n', ME.message);
    fprintf(errors, 'Error ID: %s\n', ME.identifier);
    % save failed things to run again?
    % critical errors - stop the loop?

end

fclose(logs);
fclose(errors);

% Note - processing on praegu mega aeglane, kuue pildi jaoks läks äkki 3min?
% kas startupi saab kiirendada?