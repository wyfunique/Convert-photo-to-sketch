img = imread('your picture path');
figure(1); imshow(img);

% Make image lighter.
img = uint8(double(img) .* 1.5);
figure(2); imshow(img);

% Threshold for curve adjusting : During curve adjusting, the pixels whose
% values are less than this threshold will be set to 0. 
white_threshold = 40;

img_res = convert2Sketch(img, white_threshold);
