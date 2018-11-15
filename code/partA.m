clear;clc;
filepath=strcat('./Images/Images', '/', 'test_color.JPG');
A = imread(filepath);
A_SIZE= size(A);
A_gray = rgb2gray(A);
[nr nc] =size(A_gray);
imwrite(A_gray, 'test_gray.jpg');
Sx=[-1 0 1; -2 0 2; -1 0 1];
Sy=[-1 -2 -1; 0 0 0; 1 2 1];
Ax=imfilter(double(A_gray), Sx);
Ay=imfilter(double(A_gray), Sy);
figure, imshow(A), impixelinfo
figure, imshow(A_gray), impixelinfo
figure, imshow(mat2gray(Ax)), impixelinfo
figure, imshow(mat2gray(Ay)), impixelinfo
