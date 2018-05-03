% img = rgb2gray(im2double(imread('corner2.gif')));
% img = im2double(imread('corner2.gif'));

img = imread('lab.gif');
if (size(img,3) ~= 1)
    img = rgb2gray(img);
else
    img = img;
end
img = im2double(img);
[Corner_SUSAN,count] = SUSAN_corner_detect(img);
figure(6)
imshow(img),hold on
plot(Corner_SUSAN(:,2),Corner_SUSAN(:,1),'g.')