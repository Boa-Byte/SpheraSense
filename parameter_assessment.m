
% Organise the whole thing into a function
% Input = Probabilities file
% Output = Spheroid area

% Get spheroid size, count pixels with >= 90% probability

h5_path = "C:\Users\Kasutaja\Desktop\BSc_thesis\210816_100259_Plate 1_mini\set_of_six_Probabilities\A1_03_1_1Z2_Bright Field_001_Probabilities.h5";
img_path = "C:\Users\Kasutaja\Desktop\BSc_thesis\210816_100259_Plate 1_mini\set_of_six\A1_03_1_1Z2_Bright Field_001.tif";

metadata = imfinfo(img_path).ImageDescription;

data = h5read(h5_path, '/exported_data');
disp(['Data shape: ', num2str(size(data))]); % Shape (c,x,y)
num_classes = size(data, 1);
show_class = 1; % spheroid = 1, background = 2

show = permute(data,[3,2,1]); % I want (y,x,c)
spheroid_probability_map = show(:, :, show_class);

%threshold = 0.9;
%pixelcount = sum(spheroid_probability_map(:) >= threshold);
pixelcount = 1;
spheroid_area = pixelcount * microns_per_pixel(metadata);

disp(['Spheroid area (pixels): ', num2str(pixelcount)]);
disp(['Spheroid area (µm^2): ', num2str(spheroid_area)]);

% for display
disp_data = show( :, :, show_class);
figure;
imagesc(disp_data);
axis image;
colorbar;
title('Probability map for spheroid_class');
axis off;

%bw = imbinarize(img);
%montage({img, bw});
%imshow(bw)

% TO-DO:
% fix axes, export ilastiku probabilities kujuga xyc (standard)
% võrdle threshi fillholes vs no fillholes
% uurida matlab function handles
% sferoidi ruumala? metadatas Z planeide omavahelised kaugused


function realarea = microns_per_pixel(metadata)

    width_pixels = XMLStringToVariable(metadata).ImageAcquisition.PixelWidth;
    height_pixels = XMLStringToVariable(metadata).ImageAcquisition.PixelWidth;

    width_microns = XMLStringToVariable(metadata).ImageAcquisition.ImageWidthMicrons;
    height_microns = XMLStringToVariable(metadata).ImageAcquisition.ImageHeightMicrons;
    
    S_pixels = str2double(width_pixels)*str2double(height_pixels);
    S_microns = str2double(width_microns)*str2double(height_microns);
    realarea = S_microns/S_pixels;
    % with 4x objective 1 px = 1.6125 µm

end


% useful metadata variables:

% <Time>10:22:18</Time>
% <Well>A1</Well>
% <PlateType>Greiner 96 round bottom- Copy for spheroid</PlateType>
% <KineticStartDate>08/16/21</KineticStartDate>
% <KineticStartTime>10:22:17</KineticStartTime>
% <KineticSequence>0</KineticSequence>
% <KineticTimeMs>0</KineticTimeMs>
% <KineticReadsTotal>1</KineticReadsTotal>
% <KineticIntevalMs>0</KineticIntevalMs>
%
% <ZStackTotal>7</ZStackTotal>
% <ZStackFocalPosition>4</ZStackFocalPosition>
% <ZStackPosition>1</ZStackPosition>
%
% <ObjectiveSize>10</ObjectiveSize>
%
% <Channel Color="Bright Field">