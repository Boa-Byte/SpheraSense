
% Run ilastik headless
% Add saving to a separate folder

% Find any version of Ilastik.exe from user computer
basePath = 'C:\Program Files\';
wildcardPath = dir(fullfile(basePath, 'ilastik*'));
if ~isempty(wildcardPath)
    ilastik_path = fullfile(basePath, wildcardPath(1).name, 'ilastik.exe'); % get full path
else
    error('Ilastik not found among Program Files.');
end

%ilastik_path -> from app

% Dynamic choice needed here
ilastik_proj_path = 'C:\Users\Kasutaja\Desktop\BSc_thesis\testrun\draft1.ilp';
imfolder = 'C:\Users\Kasutaja\Desktop\BSc_thesis\210816_100259_Plate 1_minifun';
cd(imfolder);

% Generate batches of terminal commands < 8191 char (Windows default limit)

images = dir(fullfile(imfolder,'*.tif'));
cmds = struct('command', {});
batch_nr = 0;
i = 1;

while i <= numel(images)

    cmd = sprintf('"%s" --headless --project="%s" "%s"', ...
        ilastik_path, ...
        ilastik_proj_path, ...
        images(i).name);
    
    cmd_length = length(cmd);
    i = i+1;
    
    % Keep adding images if within the character limit
    while i <= numel(images)
        
        img_str = sprintf(' "%s"', images(i).name);
        
        if cmd_length + length(img_str) >= 8191
            break;
        end

        cmd = strcat(cmd, img_str);
        cmd_length = length(cmd); % Update command length
        i = i+1;                  % Move to the next image
    
    end

    % Finalize batch
    batch_nr = batch_nr + 1;
    cmds(batch_nr).command = cmd;
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