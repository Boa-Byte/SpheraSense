% Image morphology operations
% Binarize

h5_path = "C:\Users\Kasutaja\Desktop\BSc_thesis\210816_100259_Plate 1_mini\set_of_six_Probabilities\A4_03_1_1Z2_Bright Field_001_Probabilities.h5";
img_path = "C:\Users\Kasutaja\Desktop\BSc_thesis\210816_100259_Plate 1_mini\set_of_six\A4_03_1_1Z2_Bright Field_001.tif";
%img = imread("A4_03_1_1Z2_Bright Field_001.tif");

metadata = imfinfo(img_path).ImageDescription;

data = h5read(h5_path, '/exported_data');
disp(['Data shape: ', num2str(size(data))]); % Shape (c,x,y)
num_classes = size(data, 1);
show_class = 1; % spheroid = 1, background = 2

show = permute(data,[3,2,1]); % I want (y,x,c)
spheroid_probmap = show(:, :, show_class);

threshold = 0.7;
binaryimage = spheroid_probmap >= threshold;

binary_image_filled = imfill(binaryimage, 'holes');
convex_hull = bwconvhull(binary_image_filled);
boundaries = bwboundaries(convex_hull);
boundary = boundaries{1};

stats = regionprops(binary_image_filled, 'Centroid', 'MajorAxisLength', 'MinorAxisLength');
imshow(binaryimage);
hold on;

% Boundary points of the convex hull
plot(boundary(:,2), boundary(:,1), 'r-', 'LineWidth', 1); % Plot the convex hull outline
distances = pdist2(boundary, boundary); % Pairwise distances between all points on the boundary

% Find the indices of the largest dist
[~, max_idx] = max(distances(:));
[max_row, max_col] = ind2sub(size(distances), max_idx);

plot([boundary(max_row, 2), boundary(max_col, 2)], ...
     [boundary(max_row, 1), boundary(max_col, 1)], ...
     'g-', 'LineWidth', 2);

hold off;


%montage({binaryimage, binary_image_filled, convex_hull, boundaries{1}});

% largest_diameter = stats(1).MajorAxisLength;
% smallest_diameter = stats(1).MinorAxisLength;
% centroid = stats(1).Centroid;

%imshow(binaryimage);
%hold on;
%plot([stats(1).Centroid(1), stats(1).Centroid(1) + largest_diameter], [stats(1).Centroid(2), stats(1).Centroid(2)], 'g-', 'LineWidth', 2); % Draw the major axis
%plot([stats(1).Centroid(1), stats(1).Centroid(1) + smallest_diameter], [stats(1).Centroid(2), stats(1).Centroid(2)], 'r-', 'LineWidth', 2);
%hold off;
%disp(['Largest Diameter: ', num2str(largest_diameter), ' pixels']);

pixelcount = sum(spheroid_probmap(:) >= threshold);
disp(['Spheroid area (pixels): ', num2str(pixelcount)]);
%spheroid_area = pixelcount * microns_per_pixel(metadata);

% for display
% disp_data = show( :, :, show_class);
% figure;
% imagesc(disp_data);
% axis image;
% colorbar;
% title('Probability map');
% axis off;

% figure;
% bw = imbinarize(disp_data);
% 
% level = graythresh(disp_data);
% level2 = graythresh(img);
% BW = imbinarize(disp_data, level);
% 
% sensitivity = 0.5; % controls thresh strictness
% BW2 = imbinarize(disp_data, 'adaptive', 'Sensitivity', sensitivity);
% 
% %montage({img, bw, BW, BW2});
% 
% imshow(disp_data);
% imcontrast

%imshow(edge(disp_data, 'canny')); %prewitt, sobel

% graythresh, otsuthresh, adaptthresh, imageSegmenter
% imquantize, multithresh(I,thresh)

% TO-DO:
% uurida matlab function handles
% sferoidi ruumala? metadatas Z planeide omavahelised kaugused