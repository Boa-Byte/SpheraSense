
% input filename of some other channel image
% match to corresponding Bright Field image
% output BF image path

% logic: everything matches except ChannelIndex and ChannelName

function BF_file = match_to_BF(RFP_file, filenames_data)
        
    RFPparts = regexp(RFP_file, '[_.]', 'split');
    [RWellID, RReadIndex, ~, RZIndex, ~, RCycleIndex] = RFPparts{:};
    
    for n = 1:numel(filenames_data)
        
        BFparts = regexp(filenames_data(n).FileName, '[_.]', 'split');
        [WellID, ReadIndex, ~, ZIndex, ~, CycleIndex] = BFparts{:};
       
         if isequal(RWellID, WellID) && isequal(RReadIndex, ReadIndex) && isequal(RZIndex, ZIndex) && isequal(RCycleIndex, CycleIndex)
            %BF_file = filenames_data(n).FileName;
            BF_file = erase(filenames_data(n).FileName, '.tif');
            %BF_file = filenames_data(n).FilePath;
            return;
         end
    end           
end
