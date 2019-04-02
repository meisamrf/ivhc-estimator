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
figure;imshow(im);

% noise estimation %
im_n = double(im);
[est_sigma_p,est_sigma_o] = imnest_ivhc(im_n,0);


disp('----- Denoising without processing degree adjustment -----')
[~, y_est1] = BM3D(1, im_n, est_sigma_p);
figure;imshow(y_est1);title('Noise is estimated by IVHC');


disp('----- Denoising with processing degree adjustment -----')

[~, y_est2] = BM3D(1, im_n, est_sigma_o);
figure;imshow(y_est2);title('Noise is estimated by IVHC adjusted by gamma');


disp('----- Denoising with noise clinic -----')

img2file(im_n,'I',0);
tic;
!noiseclinic.exe
elapsed_time_clinic = toc;

clinic_res = dlmread('_noiseCurves_All_0.txt');
sig_clinic = mean(clinic_res(:,2));

[~, y_est3] = BM3D(1, im_n, sig_clinic);
figure;imshow(y_est3);title('Noise is estimated by noise clinic');
