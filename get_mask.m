
% Input: binary image of spheroid
% Output: binary mask covering only spheroid area (=1), type=logical

function mask = get_mask(binaryimage)

    CC = bwconncomp(binaryimage);
    stats = regionprops(CC, 'Area');      % get area of each component
    [~, largest_idx] = max([stats.Area]); % index of the largest connected component
    largest_object_indices = CC.PixelIdxList{largest_idx}; % Individual pixel coords -> mask
    
    mask_base = zeros(size(binaryimage));
    mask_base(largest_object_indices) = 1;

    mask = logical(mask_base);

%     figure;
%     subplot(1,2,1);
%     imshow(binaryimage); % Show the original binary image
%     title('Original Binary Image');
%     
%     mask_rgb = cat(3, zeros(size(mask)), zeros(size(mask)), mask); 
%     
%     subplot(1,2,2);
%     imshow(mask_rgb); % Show the mask
%     title('Mask Applied');

end

% "C:\Users\Kasutaja\Desktop\BSc_thesis\1A_small_sets_testing\1A_241128_111010_Plate 1_try\A1_03_1_1_Bright Field_001.tif"
% inputImage = imread("A1_03_1_1_Bright Field_001.tif");
% binaryImage = imbinarize(inputImage);

