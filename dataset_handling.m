
% README
% Functions in this file:
%
% dataset_handling(folder_path)
%   - input = microscopy images folder path in single quotes ''
%   - output = master dataset "filenames_data"
%
% AN(filenames_data)
%   - sorts filenames_data alphanumerically by WellID


function [filenames_data, nonmatch_files] = dataset_handling(folder_path)

    filenames = dir(fullfile(folder_path, '*.tif'));
    nr_images = numel(filenames);
    
    pattern = '(?<WellID>[A-Z]\d{1,2})_(?<ReadIndex>\d+)_(?<ChannelIndex>\d+)_(?<ZIndex>\w{3})_(?<ChannelName>[\w\s]+)_(?<CycleIndex>\d+)';
   
    filenames_data = struct('FilePath', {}, 'FileName', {}, 'WellID', {}, 'ReadIndex', {}, 'ChannelIndex', {}, 'ZIndex', {}, 'ZPlane', {}, 'ChannelName', {}, 'CycleIndex', {});
    nonmatch_files = {};

    % Create main database
    for n = 1:nr_images
        
        f = filenames(n).name;
        file_match = regexp(f, pattern, 'names');
        
        % Set aside files that don't match regex
         if isempty(file_match)
            nonmatch_files{end+1} = f;
            continue
         else
            file_data = struct();
            file_data.FilePath = fullfile(folder_path, f);
            file_data.FileName = f;
            file_data.WellID = file_match.WellID;
            file_data.ReadIndex = str2double(file_match.ReadIndex);
            file_data.ChannelIndex = str2double(file_match.ChannelIndex);
            file_data.ZIndex = file_match.ZIndex;
            file_data.ZPlane = str2double(file_match.ZIndex(3));
            file_data.ChannelName = file_match.ChannelName;
            file_data.CycleIndex = str2double(file_match.CycleIndex);
        
            filenames_data(end+1) = file_data;
        end
    end
    
    % Sort
    filenames_data = AN(filenames_data);

end

% Sort filenames_data alphanumerically by WellID
function sorted = AN(filenames_data)

    wellIDs = {filenames_data.WellID};
    letters = cell(size(wellIDs));
    numbers = zeros(size(wellIDs));

    for i = 1:length(wellIDs)
        wellID = wellIDs{i};
        letters{i} = wellID(1);
        numbers(i) = str2double(wellID(2:end));
    end

    [~, sorted_idx] = sortrows([cell2mat(letters'), numbers']);  % Sort by letters, then by numbers
    sorted = filenames_data(sorted_idx);                         % Reorder filenames_data based on sorted indices

end
