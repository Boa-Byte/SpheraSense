
% Input = choose microscopy images folder
% Output = master dataset "filenames_data"

% Extract info from filenames

function filenames_data = dataset_handling(folder_path)

    filenames = dir(fullfile(folder_path, '*.tif'));
    nr_images = numel(filenames);
    
    pattern = '(?<WellID>\w+)_(?<ReadIndex>\d+)_(?<ChannelIndex>\d+)_(?<ZIndex>\w+)_(?<ChannelName>[\w\s]+)_(?<CycleIndex>\d+)';
    filenames_data = struct('FilePath', {}, 'WellID', {}, 'ReadIndex', {}, 'ChannelIndex', {}, 'ZIndex', {}, 'ZPlane', {}, 'ChannelName', {}, 'CycleIndex', {});
    
    % Create main database
    for n = 1:nr_images
        
        f = filenames(n).name;
        file_data = regexp(f, pattern, 'names');
        % To-do: Set aside files that don't match regex!

        % Add fields FilePath and ZPlane
        file_data.FilePath = fullfile(folder_path, f);
        file_data.ZPlane = str2double(file_data.ZIndex(3));
    
        filenames_data(n) = file_data; 
    end
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

% value = 'A3'; % User chosen well, show only relevant data
% wellIDs = {filenames_data_sorted.WellID};
% well_selected = filenames_data_sorted(strcmp(wellIDs, value));
% 
% z_value = 2;
% %zplanes = [well_selected.ZPlane];
% %z_selected = well_selected(zplanes == z_value);
% 
% z_selected = well_selected([well_selected.ZPlane] == z_value);
