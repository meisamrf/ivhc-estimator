% demo for estimation of frequency-dependent (Processed) image noise
clc
clear
close all
rng('default');
%

im = imread('peppers.png');

disp('----- Isotropic spatially correlated noise -----')

for sigma_a = [10 15]    
    for sigma_GB = [0.45 0.5 0.55]
        h = fspecial('gaussian', 3, sigma_GB);
        noise = sigma_a*randn(size(im));
        noise = imfilter(noise,h,'symmetric'); 
        noise_std = std(noise(:));
        im_n = double(im) + noise;
        [est_sigma_p,est_sigma_o,nlf] = imnest_ivhc(im_n,0);          
        est_error = abs(noise_std-est_sigma_p);
        est_gamma = est_sigma_o/est_sigma_p;
        disp('------------------------')
        disp(['sigma_GB = ' num2str(sigma_GB) ', sigma_a =  ' num2str(sigma_a) ', sigma_n =  ' num2str(noise_std)])
        disp(['Noise std estimation error: ' num2str(est_error)])
        disp(['Estimated processing degree: ' num2str(est_gamma)])
        disp('------------------------')
    end
end
    
disp('************************************************')
disp('----- Anisotropic spatially correlated noise -----')
disp('************************************************')

for sigma_a = [10 15]    
    for scale = [0.5 1 2]
        h = fspecial('gaussian', 3, sigma_GB);
        noise = sigma_a*randn(size(im));
        noise = bilateralflt(noise,sigma_a*sigma_a*scale,1,1);
        noise_std = std(noise(:));
        im_n = double(im) + noise;
        [est_sigma_p,est_sigma_o] = imnest_ivhc(im_n,0);       
        est_error = abs(noise_std-est_sigma_p);
        est_gamma = est_sigma_o/est_sigma_p;
        disp('------------------------')
        disp(['sigma_BL = ' num2str(sigma_a*scale) ', sigma_a =  ' num2str(sigma_a) ', sigma_n =  ' num2str(noise_std)])
        disp(['Noise std estimation error: ' num2str(est_error)])
        disp(['Estimated processing degree: ' num2str(est_gamma)])
        disp('------------------------')
    end
end