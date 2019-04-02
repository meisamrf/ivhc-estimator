function [sigma_p,sigma_o,var_nlf,elapsed_time] = imnest_ivhc(A,max_poly_deg)

%=====================================================================
% Image noise estimation based on intensity-variance
% homogeneity classification (IVHC)
% Written by Meisam Rakhshnfar, Vidpro Lab
% (http://users.encs.concordia.ca/~amer/SDQI/)
% Revised: March 2016
%
% Copyright Notice:
% Copyright (c) 2011-2016 Concordia University
% All Rights Reserved.
%===================================================================== 

% imnest_ivhc(A)
 
%   A can be an M-by-N (grayscale image) or M-by-N-by-3 (rgb color image)
%   array.  A cannot be an empty array or very small matrix.

%   max_poly_deg is the max of degree for polynomial regression 

%  OUTPUTS:
%   sigma_p is variance of noise in the Y channel at highest rank noise
%   representative cluster. Under signal-independent noise, sigma_p
%   estimates the standard deviation of noise. Under signal-dependent
%   noise, sigma_p is likely to be the peak of the noise. However, the more
%   accurate peak is estimated by var_nlf.
%
%   sigma_o = sigma_p*gamma, where gamma is the degree of processing. When
%   the noise is white, gamma = 1;
%
%   var_nlf is the noise level (variance) function
%
%   elapsed_time: execution time

%%%
%%% parse input parameters
%%%
if (nargin==0)
    error('Input image is required');
elseif (nargin == 1)
    max_poly_deg = 5; 
elseif (nargin>2)
   error('Too many input parameters');
end
    
if (size(A,3)==3)
    % input assmed to RGB
    A = rgb2ycbcr(A);
    A = single(A(:,:,1));
elseif (size(A,3)==1)
    A = single(A);
else
    error('Input image should be either grayscale or RGB');
end
    
if (any(size(A)<128))
    error('Too Small Image');
end
if (size(A,1)>1080) || (size(A,2)>1920)
    error('Image size is not supported');
end


% call mex function of IVHC
tic;
[a, b] = imnestivhc(single(A));
elapsed_time = toc;

sigma_p = double(a(1));
sigma_o = double(a(2));

%cluster intensity
clusters_iy = b(1:3:end);
%binary weighting 
clusters_bw = b(2:3:end);
clusters_bw = clusters_bw/min(clusters_bw);
%binary weighting 
clusters_var = b(3:3:end);

% ---- NLF regression -------
% normalize
nlf_v = clusters_var/(sigma_p*sigma_p);
nlf_i = clusters_iy/255;

nlf_i_ext = [nlf_i nlf_i(clusters_bw>1)];
nlf_v_ext = [nlf_v nlf_v(clusters_bw>1)];

[nlf_i_sort,sort_idx] = sort(nlf_i_ext);
nlf_v_sort = nlf_v_ext(sort_idx);

max_poly_deg = floor(max_poly_deg/2)+1;

if (length(nlf_v_sort)>1)
    last_mse = 1;
    for k = 0:max_poly_deg        
        est_pol = polyfit(nlf_i_sort,nlf_v_sort,min(1+k*2,length(nlf_i_sort)-1));
        nlf_reg = polyval(est_pol,nlf_i_sort);
        mse = mean((nlf_reg-nlf_v_sort).^2);
        if (mse<0.002 || (last_mse-mse)/mse<0.5)
            break;
        end
        last_mse = mse;
    end
    
    nlf_i_sort = sort(nlf_i);
    nlf_reg = polyval(est_pol,nlf_i_sort);
else
    nlf_reg = nlf_v;
    nlf_i_sort = sort(nlf_i);
end
v = [nlf_reg(1) nlf_reg nlf_reg(end)];
x = [0 nlf_i_sort 1];
var_nlf = interp1(x,v,(0:255)/255,'pchip')*sigma_p*sigma_p;


