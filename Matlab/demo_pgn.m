% demo for estimation of signal-dependent (mixed Possionian-Gaussian) image noise
clc
clear
close all
rng('default');
%
im = imread('sample1.png');

% generate signal-dependent noise
sigma_noise = 8;
nlf_root = sigma_noise*(.4+(0:255)/255);
nlf = nlf_root.^2;
noise = randn(size(im)).*nlf_root(floor(im)+1);
% generate noisy image
im_n = double(im)+noise;

[est_sigma_p,est_sigma_o,est_var_nlf,elapsed_time] = imnest_ivhc(im_n);

disp(['elapsed_time:' num2str(elapsed_time)])
figure; imshow(im_n,[]);
figure;plot(est_var_nlf)
hold on;
plot(nlf,'r')

rmse_var = sqrt(mean((est_var_nlf-nlf).^2));
maxe_var = max(abs(est_var_nlf-nlf));

disp(['RMSE of estimated noise variance:' num2str(rmse_var)])
disp(['Max error of estimated noise variance:' num2str(maxe_var)])


rmse_std = sqrt(mean((sqrt(est_var_nlf)-sqrt(nlf)).^2));
maxe_std = max(abs(sqrt(est_var_nlf)-sqrt(nlf)));

disp(['RMSE of estimated standard deviation:' num2str(rmse_std)])
disp(['Max error of estimated standard deviation:' num2str(maxe_std)])



