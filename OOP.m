
% Copy of dataset_handling but an effort to make it object-oriented instead
% Very much a work in progress

classdef Image

    properties
        filename;
        filepath;
    end

    methods
        function obj = Image(filename,filepath)
            obj.filename = filename;
            obj.filepath = filepath;
        end

        %function y = get_prop(obj)
end


% folder_path = uigetdir('C:\Users\Kasutaja\Desktop\BSc_thesis');
% filenames = dir(fullfile(folder_path, '*.tif'));
% nr_images = numel(filenames);
% file_paths = cell(nr_images, 1);

pattern = '(?<WellID>\w+)_(?<ReadIndex>\d+)_(?<ChannelIndex>\d+)_(?<ZIndex>\w+)_(?<ChannelName>[\w\s]+)_(?<CycleIndex>\d+)';
filenames_data = struct('FilePath', {}, 'WellID', {}, 'ReadIndex', {}, 'ChannelIndex', {}, 'ZIndex', {}, 'ZPlane', {}, 'ChannelName', {}, 'CycleIndex', {});

% Create main database (filenames_data)- Save path + Extract data from filenames

for n = 1:nr_images
    
    f = filenames(n).name;
    file_data = regexp(f, pattern, 'names');
    
    % New fields- FilePath and ZPlane
    file_paths{n} = fullfile(folder_path, f);
    file_data.FilePath = file_paths{n};

    zindex_str = file_data.ZIndex;
    z_plane = str2double(zindex_str(3));
    file_data.ZPlane = z_plane;

    filenames_data(n) = file_data;

end

% Sort filenames_data by WellID
wellIDs = {filenames_data.WellID};

% Loop to separate letters and numbers
% + Capture unique IDs (for well options display)

letters = cell(size(wellIDs));
numbers = zeros(size(wellIDs));

for i = 1:nr_images
    wellID = wellIDs{i};
    letters{i} = wellID(1);
    numbers(i) = str2double(wellID(2:end));
end

[~, sorted_idx] = sortrows([cell2mat(letters'), numbers']); % Sort by letters, then by numbers
filenames_data_sorted = filenames_data(sorted_idx);         % Reorder filenames_data based on sorted indice

wellIDs = {filenames_data_sorted.WellID};
uniqueIDs = unique(wellIDs, 'stable');

%zplane_values = unique(cell2mat({filenames_data_sorted.ZPlane}));