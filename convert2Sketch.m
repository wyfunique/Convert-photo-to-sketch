function [ res ] = convert2Sketch( img, white_threshold )
    scope = 255 / (255-white_threshold);
    b = -scope * white_threshold;
    [m, n, c] = size(img);
    
    % Remove colors
    if c > 1
        img_gray(:,:,1) = rgb2gray(img);   
        img_gray(:,:,2) = rgb2gray(img);   
        img_gray(:,:,3) = rgb2gray(img);
    else
        img_gray(:,:,1) = img;   
        img_gray(:,:,2) = img;   
        img_gray(:,:,3) = img;
    end
    figure('Name', 'Remove colors');  imshow(img_gray); 
    
    % Adjust curve
    for i=1:m
        for j=1:n
            if img_gray(i, j, 1) <= white_threshold
                img_gray(i, j, :) = zeros(1,1,3);
            else
                img_gray(i, j, :) = scope * img_gray(i, j, :) + b;
            end
        end
    end
    figure('Name','Adjust curve'); imshow(uint8(img_gray));
    
    % Copy layer 1 to layer 2 and reverse colors.
    img_gray2 = zeros(m, n, 3);
    img_mix = zeros(m, n, 3);
    for i=1:m
        for j=1:n
            img_gray2(i, j, 1) = 255 - img_gray(i, j, 1);
            img_gray2(i, j, 2) = 255 - img_gray(i, j, 2);
            img_gray2(i, j, 3) = 255 - img_gray(i, j, 3);
        end
    end
    
    % Min filter
    radius = 1;
    img_gray2 = min_filter(img_gray2, radius);
    figure('Name', 'Min filter'); imshow(uint8(img_gray2));
    
    % Mix layers
    img_mix = color_dodge(img_gray2, img_gray);
    res = uint8(img_mix);
    figure('Name', 'Mix layers'); imshow(res); 
end

% Function for layer mixture
function res = color_dodge(layer1, layer2)
    %((uint8)((B == 255) ? B:min(255, ((A << 8 ) / (255 - B)))))
    [m, n, c] = size(layer2);
    if c == 1
        res = zeros(m, n);
        for i=1:m
            for j=1:n
                if layer2(i, j) == 255
                    res(i, j) = 255;
                else
                    res(i, j) = min(255, (layer1(i, j)*256 / (255 - layer2(i, j))));
                end
            end
        end
    else
        res = zeros(m, n, c);
        for i=1:m
            for j=1:n
                for k=1:c
                    if layer2(i, j, k) == 255
                        res(i, j, k) = 255;
                    else
                        res(i, j, k) = min(255, (layer1(i, j, k)*256 / (255 - layer2(i, j, k))));
                    end
                end
            end
        end
    end
end

% Function for min filter
function res = min_filter(img, radius)
    [m, n, c] = size(img);
    filter_width = 1 + 2 * radius;
    if c == 1
        res = zeros(m, n);
        for i=1:m-2*radius
            for j=1:n-2*radius
                current_min = min(min(img(i:i+2*radius, j:j+2*radius)));
                res(i:i+2*radius, j:j+2*radius) = ones(filter_width, filter_width) * double(current_min);
            end
        end   
    else
        res = zeros(m, n, c);
        for i=1:m-2*radius
            for j=1:n-2*radius
                for k=1:c
                    current_min = min(min(img(i:i+2*radius, j:j+2*radius, k)));
                    res(i:i+2*radius, j:j+2*radius, k) = ones(filter_width, filter_width) * double(current_min);
                end
            end
        end   
    end
end

% Function for max filter
function res = max_filter(img, radius)
    [m, n, c] = size(img);
    filter_width = 1 + 2 * radius;
    if c == 1
        res = zeros(m, n);
        for i=1:m-2*radius
            for j=1:n-2*radius
                current_max = max(max(img(i:i+2*radius, j:j+2*radius)));
                res(i:i+2*radius, j:j+2*radius) = ones(filter_width, filter_width) * double(current_max);
            end
        end  
    else
        res = zeros(m, n, c);
        for i=1:m-2*radius
            for j=1:n-2*radius
                for k=1:c
                    current_max = max(max(img(i:i+2*radius, j:j+2*radius, k)));
                    res(i:i+2*radius, j:j+2*radius, k) = ones(filter_width, filter_width) * double(current_max);
                end
            end
        end  
    end
end
