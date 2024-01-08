clc;
clear;
close all;

%real image
% image = imread('mlts_frames/mlts_025.png');

%synthetic image
image = imread('project_dataset_2/synthetic/kodim18_input.png');


figure, imshow(image)
title('original')
image = im2double(image);
[row, col, ch] = size(image);

% if ch == 3
%     image = rgb2gray(image);
% end

%sobel edge detection
G = [-1 0 1
    -2 0 2 
    -1 0 1];

sobel = conv2(image, G, 'same');
% figure, imshow(sobel);
% title('Sobel Operator')

%canny edge detection
canny = edge(sobel, 'canny');
% figure, imshow(canny)
% title('Canny Operator');

%opening morphology
structelem = strel('rectangle',[17,1]); %using 17x1 structuring element
opening = imopen(canny, structelem);
% figure, imshow(opening);
% title('Open Operator')

%dilation to make line longer and thicker
structelem2 = strel('rectangle',[17,3]); 
final = imdilate(opening,structelem2);
% figure, imshow(final);
% title('Dilation Operator')

%masking
detected = zeros(row,col,3);

for i = 1:row
    for j = 1:col
        if final(i,j) ~= 1
            detected(i,j,1) = image(i,j);
            detected(i,j,3) = image(i,j);
        else
            detected(i,j,2) = final(i,j);
        end
    end
end
figure, imshow(detected);
title('Masked Image');

%linear interpolation 
new = image;

for j = 1:row
    for i = 2:col-1
        if (final(j,i) == 1 && final(j,i-1) == 0) %check for pixel value before scratch
            x1 = i-1;
            y1 = image(j,i-1);
            
            for z = i:col-1
                if (final(j,z) == 1 && final(j,z+1) == 0) %check for pixel value after scratch
                    x2 = z+1;
                    y2 = image(j,z+1);
                    break
                end
            end
               
            p = polyfit([x1,x2],[y1,y2],1); %linear equation between two points
            a = p(1);
            b = p(2);

            for x = x1:x2
                new(j,x) = a*x+b;
            end
        end
    end
end



fixedIm = medfilt2(new, [5 5]); %median filter to remove any noises  
figure, imshow(fixedIm)
title('Restored Image');


