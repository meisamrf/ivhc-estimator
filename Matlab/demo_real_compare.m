% demo for estimation of real noise
clc
clear
close all

if isempty(dir('./BM3D'))
    disp('please download bm3d matlab file and place it in the current folder.')
    break;
else
    addpath './BM3D'
end

im = imread('jfk.png');
subplot(1,3,1);imshow(im);

% noise estimation %
im_n = double(im);
[est_sigma_p,est_sigma_o] = imnest_ivhc(im_n,0);


disp('----- Denoising without processing degree adjustment -----')
[~, y_est1] = BM3D(1, im_n, est_sigma_p);
subplot(1,3,2);imshow(y_est1);


disp('----- Denoising with processing degree adjustment -----')

[~, y_est2] = BM3D(1, im_n, est_sigma_o);
subplot(1,3,3);imshow(y_est2);


