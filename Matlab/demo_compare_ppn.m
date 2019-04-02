% demo for estimation of frequency-dependent (processed) image noise

clc
clear
close all
rng('default');

im = imread('peppers.png');

disp('----- AWGN estimation -----')

sigma_GB = 0.5;
h = fspecial('gaussian', 3, sigma_GB);

for sigma_a = [10 15]
    
    noise = sigma_a*randn(size(im));
    noise = imfilter(noise,h,'symmetric'); 
    noise_std = std(noise(:));
    im_n = double(im) + noise;
    [est_sigma_p,est_sigma_o,nlf,elapsed_time] = imnest_ivhc(im_n,0);
    est_error_ivhc = abs(noise_std-est_sigma_p);
 
    img2file(im_n,'I',0);
    tic;
    !noiseclinic.exe
    elapsed_time_clinic = toc;
            
    clinic_res = dlmread('_noiseCurves_All_0.txt');
    est_error_clinic = abs(noise_std-mean(clinic_res(:,2)));

    disp(['sigma_n =  ' num2str(noise_std)])
    disp('------------------------')
    disp(['elapsed time of IVHC: ' num2str(elapsed_time) ',  elapsed time of clinic: ' num2str(elapsed_time_clinic)])
    
    disp(['Noise std estimation error for IVHC: ' num2str(est_error_ivhc)])
    disp(['Noise std estimation error for noise clinic: ' num2str(est_error_clinic)])
    disp('------------------------')
end


