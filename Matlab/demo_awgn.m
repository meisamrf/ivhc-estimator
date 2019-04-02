% demo for estimation of image noise (AWGN)
clc
clear
close all
rng('default');

im = imread('kodim04.png');

disp('----- Synthetic AWGN -----')

for sigma_a = [5 10 15]
    
    noise = sigma_a*randn(size(im));
    noise_std = std(noise(:));
    im_n = double(im) + noise;
    [est_sigma_p,est_sigma_o,nlf] = imnest_ivhc(im_n,0);
    est_error = abs(noise_std-est_sigma_p);
    disp('------------------------')
    disp(['sigma_a =  ' num2str(sigma_a) ', sigma_n =  ' num2str(noise_std)])
    disp(['Noise std estimation error: ' num2str(est_error)])
    disp('------------------------')
end


