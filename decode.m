
function [C,goodpixels] = decode(imageprefix,start,stop,threshold)

% function [C,goodpixels] = decode(imageprefix,start,stop,threshold)
%
%
% Input:
%
% imageprefix : a string which is the prefix common to all the images.
%
%                  for example, pass in the prefix '/home/fowlkes/left/left_'  
%
%                  to load the image sequence   '/home/fowlkes/left/left_01.png' 
%                                               '/home/fowlkes/left/left_02.png'
%                                               '/home/fowlkes/left/left_03.png'
%                                                          etc.
%
%  start : the first image # to load
%  stop  : the last image # to load
% 
%  threshold : the pixel brightness should vary more than this threshold between the positive
%             and negative images.  if the absolute difference doesn't exceed this value, the 
%             pixel is marked as undecodeable.
%
% Output:
%
%  C : an array containing the decoded values (0..1023)  for 10bit values
%
%  goodpixels : a binary image in which pixels that were decodedable across all images are marked with a 1.

% ensure that stop is not greater than start
if (stop<=start)
    error('stop frame number should be greater than start frame number');
end

% ensure that at least first image exists
if exist(strcat(imageprefix, sprintf('%02d',start), '.png'), 'file') ~= 2
    error('file(s) do not exist');
end

bit = 1;
goodpixels = [];
for i = start:2:stop

    % read first two images
    first_img = imread(strcat(imageprefix, sprintf('%02d',i), '.png'));
    second_img = imread(strcat(imageprefix, sprintf('%02d',i+1), '.png'));
    
    % convert images to grayscale if needed
    if size(first_img,3) > 1
        first_img = rgb2gray(first_img);
    end
    if size(second_img,3) > 1
        second_img = rgb2gray(second_img);
    end
    
    % ensure that images are same size
    if size(first_img) ~= size(second_img)
        error('frame dimensions do not match');
    end
    
    % convert images to double precision
    first_img = im2double(first_img);
    second_img = im2double(second_img);
    
    % calculate difference in brightness between each pixel of image
    diff = abs(first_img - second_img);
    
    % record gray code, i.e. pixels where first_img is brighter than
    % second_img
    G(:,:,bit) = first_img > second_img;
    
    % update goodpixels mask with locations of pixels that are above
    % threshold across all frames
    if isempty(goodpixels)
        goodpixels = diff > threshold;
    else
        % bitwise and ensures that every frame must meet this condition
        goodpixels = bitand(goodpixels, diff > threshold);
    end

    % visualize as we walk through the images
    figure(1); clf;
    subplot(1,2,1); imagesc(G(:,:,bit)); axis image; title(sprintf('bit %d',bit));
    subplot(1,2,2); imagesc(goodpixels); axis image; title('goodpixels');
    drawnow;

    bit = bit + 1;
end

% convert from gray to bcd
%   remember that MSB is bit #1
G_bcd(:,:,1) = G(:,:,1);

% C holds decimal conversion, starts at MSB
C = pow2(size(G,3) - 1) .* G_bcd(:,:,1);
for i = 2 : size(G,3)
    % convert to BCD according to formula
    G_bcd(:,:,i) = bitxor(G_bcd(:,:,i-1),G(:,:,i));
    
    % add next lowest power of 2 times next significant bit to decimal
    % conversion
    C = C + (pow2(size(G,3) - i) .* G_bcd(:,:,i));
end

% visualize final result
figure(1); clf;
subplot(1,2,1); imagesc(C.*goodpixels); axis image; title('decoded');
subplot(1,2,2); imagesc(goodpixels); axis image; title('goodpixels');
drawnow;

