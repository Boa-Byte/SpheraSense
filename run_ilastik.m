% README:

% run_ilastik(imfolder, ilastik_proj_path)
%   runs ilastik headless
%   outputs a folder of (imagefolder)_Probabilities, h5 probability files
% params:
%   folder_path = path to folder of microscopy images
%   ilastik_proj_path = path of Ilastik ML model (.ilp file)

% gen_cmds_ilastik(imfolder, ilastik_proj_path)
% generates commands for all .tif files in img folder

% progress = uiprogressdlg(app.UIFigure, 'Title', 'Processing', 'Message', 'Starting Ilastik...');

function run_ilastik(folder_path, ilastik_proj_path, progress)
    
    cd(folder_path);
    cmds = gen_cmds_ilastik(folder_path, ilastik_proj_path);

    n = numel(dir(fullfile(folder_path, '*.tif'))); % Total images to process
    n_done = 0;
    
    for i = 1:numel(cmds)
       
        %system(cmds(i).command); % Run a command with a batch of images
        %system(['start cmd /k "' cmds(i).command '"']);
        %system(['start /B "" "', cmds(i).command, '"']);
        system(['start cmd /c "' cmds(i).command, ' & timeout /t 5"']);
        
        expected_h5 = n_done + cmds(i).im_in_batch;
        
        while n_done < expected_h5
            pause(2)
            n_done = numel(dir(fullfile(folder_path, '*.h5')));
            progress.Value = n_done / n;
            progress.Message = sprintf('Processing image %d of %d...', n_done, n);
            drawnow;
        end        
    end
    
    % move resulting h5 files to a Probabilities folder
    h5_files = dir(fullfile(folder_path, '*.h5'));
    dest_path = [fullfile(folder_path), '_Probabilities'];
    mkdir(dest_path);
    
    for j = 1:length(h5_files)
        movefile(h5_files(j).name, dest_path);
    end

    progress.Message = 'Processing complete!';
end



function cmds = gen_cmds_ilastik(imfolder, ilastik_proj_path)

    % Find any version of Ilastik.exe from user computer
    basePath = 'C:\Program Files\';
    wildcardPath = dir(fullfile(basePath, 'ilastik*'));
    if ~isempty(wildcardPath)
        ilastik_path = fullfile(basePath, wildcardPath(1).name, 'ilastik.exe'); % get full path
    else
        error('Ilastik not found among Program Files.');
    end
    
    % Generate batches of terminal commands < 8191 char (Windows default limit)
    images = dir(fullfile(imfolder,'*.tif'));
    cmds = struct('command', {}, 'im_in_batch', {});
    batch_nr = 1;
    i = 1; % image index
    
    while i <= numel(images)
        
        % Initiate new command
        cmd = sprintf('"%s" --headless --project="%s"', ...
            ilastik_path, ...
            ilastik_proj_path);
        
        j = 0; % image count
        cmd_length = length(cmd);
                 
        while i <= numel(images)  % Add images if within the character limit
            
            img_str = sprintf(' "%s"', images(i).name);
                       
            if cmd_length + length(img_str) >= 8150 % >= 8191
                break;
            end
    
            cmd = strcat(cmd, img_str);
            cmd_length = length(cmd);       % Update command length
            j = j+1;                        % Record how many img per cmd
            i = i+1;                        % Move to the next image
            
        end
        % Finalize batch
        cmds(batch_nr).command = cmd;
        cmds(batch_nr).im_in_batch = j; 
        batch_nr = batch_nr + 1;
    end
end


% function trackprogress(imfolder)
% 
%     % Checking nr files vs nr nr files done
%     progress = uiprogressdlg(app.UIFigure, 'Title', 'Processing', 'Message', 'Starting...');
%     n = length(dir(imfolder));
%     n_done = 0;
%     
%     while n_done < n
%         progress.Value = n_done / n;
%         progress.Message = sprintf('Processing image %d of %d...', n_done, n);
%         n_done = numel(dir(fullfile(imfolder, '*.h5')));
%         pause(0.5); % Pause to avoid excessive CPU usage
%     end
%     
%     close(progress);
% end


% logFile = 'process_log.txt';
% errorLog = 'error_log.txt';
% 
% logs = fopen(logFile, 'a');
% errors = fopen(errorLog, 'a');
% 
% if logs == -1
%     error('Failed to open process_log file.');
% end
% if errors == -1
%     error('Failed to open error_log file.');
% end
% 
% cleanup = onCleanup(@() fclose('all')); % close all open files when the script ends
% 
% % Execute commands, catch errors
% try
%     for i = 1:numel(cmds)
%         fprintf(logs, 'Analyzing image %d/%d: %s', i, numel(cmds), images(i).name);
%         status = system(cmds(i).command); % Run command
%         
%         if status == 0
%             fprintf(logs, ' - Success.\n');
%             % BUG - ütleb success kui on clear error, A1_bad.tif file on
%             % saast
%         else
%             fprintf(logs, 'Image %d failed with status %d.\n', i, status);
%             fprintf(errors, 'Image %d failed: %s\n', i, cmds(i).command);
%         end
%     end
% 
% catch ME
%     fprintf(logs, 'Script interrupted with error: %s\n', ME.message);
%     fprintf(errors, 'Script interrupted with error: %s\n', ME.message);
%     fprintf(errors, 'Error ID: %s\n', ME.identifier);
%     % save failed things to run again?
%     % critical errors - stop the loop?
% 
% end
% 
% fclose(logs);
% fclose(errors);


% function runn_ilastik(imfolder, ilastik_proj_path)
% 
%     cd(imfolder);
%     cmds = gen_cmds_ilastik(imfolder, ilastik_proj_path);
% 
%     try
%         for i = 1:numel(cmds)
%             
%             status = system(cmds(i).command); % Run command
%             
%             if status == 0
%                 % batch ran successfully - log it?
%             else
%                 fprintf('Failed with status %d.\n', i, status);
%             end
%         end
%     
%     catch ME
%         disp('Script interrupted with error: %s\n', ME.message);
% 
%     end
% 
%     % move resulting h5 files to a Probabilities folder
%     h5_files = dir(fullfile(imfolder, '*.h5'));
%     dest_path = [fullfile(imfolder), '_Probabilities'];
%     mkdir(dest_path);
%     
%     for j = 1:length(h5_files)
%         movefile(h5_files(j).name, dest_path);
%     end
% 
% end