clc;
clear all;

% Reading in a folder + filename data

folder_path = 'C:\Users\Kasutaja\Desktop\BAKATÖÖ\240725_174439_Plate 1';
filenames = dir(fullfile(folder_path, '*.tif'));
nr_images = numel(filenames);

% 'F2_03_1_1Z0_Bright Field_002.tif';
% <WellID>_<Read index>_<Channel index>_<Z index>_<Channel name>_<cycle index>.tif

pattern = '(?<WellID>\w+)_(?<ReadIndex>\d+)_(?<ChannelIndex>\d+)_(?<ZIndex>\w+)_(?<ChannelName>[\w\s]+)_(?<CycleIndex>\d+)';
filenames_data = struct('WellID', {}, 'ReadIndex', {}, 'ChannelIndex', {}, 'ZIndex', {}, 'ChannelName', {}, 'CycleIndex', {});

for n = 1:nr_images
    f = filenames(n).name;
    file_data = regexp(f, pattern, 'names');
    filenames_data(n) = file_data;
end

% Format as table
%filenames_table = struct2table(filenames_data);
% disp(filenames_table)


