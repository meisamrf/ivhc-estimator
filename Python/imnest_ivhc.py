#=====================================================================
# Image noise estimation based on intensity-variance
# homogeneity classification (IVHC)
# Written by Meisam Rakhshanfar, Vidpro Lab
# (https://users.encs.concordia.ca/~amer/NEstIVHC/)
# Revised: March 2016
#
# Copyright Notice:
# Copyright (c) 2011-2019 Concordia University
# All Rights Reserved.
#===================================================================== 

import numpy as np
import skimage.color
import ivhc


def imnest_ivhc(image, max_poly_deg=5):

    '''
    # imnest_ivhc(A)
    #   A can be an M-by-N (grayscale image) or M-by-N-by-3 (rgb color image)
    #   array.  A cannot be an empty array or very small matrix.
    #   max_poly_deg is the max of degree for polynomial regression 

    #  OUTPUTS:
    #   sigma_p is variance of noise in the Y channel at highest rank noise
    #   representative cluster. Under signal-independent noise, sigma_p
    #   estimates the standard deviation of noise. Under signal-dependent
    #   noise, sigma_p is likely to be the peak of the noise. However, the more
    #   accurate peak is estimated by var_nlf.
    # 
    #   sigma_o = sigma_p*gamma, where gamma is the degree of processing. When
    #   the noise is white, gamma = 1;
    # 
    #   var_nlf is the noise level (variance) function
    #
    '''

# parse input parameters 
    if type(image) != np.ndarray:
       image = np.array(image)

    if image.ndim == 3:
        ycbcr = skimage.color.rgb2ycbcr(image)
        gray_image = np.float32(ycbcr[:,:,0])
    elif image.ndim == 2:
        gray_image = image
    else:
        print('error in image type')
        return None

    if gray_image.dtype == np.uint8:
        gray_image = np.float32(gray_image)
    elif gray_image.dtype == np.float32 or gray_image.dtype == np.float64:
        gray_image = np.float32(gray_image)
        if np.max(gray_image)<=1.0:
            gray_image = gray_image*255.0
    else:    
        print('error in image dtype')
        return None
    
    if (gray_image.shape[0]<128 or gray_image.shape[1]<128):
        print('Too Small Image')

    if (gray_image.shape[0]>3840 or gray_image.shape[1]>3840):
        error('Image size is not supported') 


    # call function of IVHC
    nlf = np.zeros((3*256,), np.float32)
    # address column-major order
    gray_image = np.transpose(gray_image.copy())
    [sigma_p, sigma_o, nlf_len] = ivhc.run(gray_image, nlf)
    nlf = nlf[0:nlf_len]
    # cluster intensity
    clusters_iy = nlf[0::3]
    # binary weighting 
    clusters_bw = nlf[1::3]
    clusters_bw = clusters_bw/min(clusters_bw)
    # binary weighting 
    clusters_var = nlf[2::3]

    # ---- NLF regression -------
    # normalize
    nlf_v = clusters_var/(sigma_p*sigma_p)
    nlf_i = clusters_iy/255.0

    nlf_i_ext = np.concatenate((nlf_i, nlf_i[clusters_bw>1]))
    nlf_v_ext = np.concatenate((nlf_v, nlf_v[clusters_bw>1]))

    sort_idx= np.argsort(nlf_i_ext)
    nlf_i_sort = nlf_i_ext[sort_idx]
    nlf_v_sort = nlf_v_ext[sort_idx]

    max_poly_deg = int(np.floor(max_poly_deg/2)+1)

    if (len(nlf_v_sort)>1):
        last_mse = 1
        for k in range(0,max_poly_deg+1):
            est_pol = np.polyfit(nlf_i_sort, nlf_v_sort, min(1+k*2,len(nlf_i_sort)-1))
            nlf_reg = np.polyval(est_pol, nlf_i_sort)
            mse = np.mean((nlf_reg-nlf_v_sort)**2)
            if (mse<0.002 or (last_mse-mse)/mse<0.5):
                break;
           
            last_mse = mse
    
        nlf_i_sort = np.sort(nlf_i)
        nlf_reg = np.polyval(est_pol, nlf_i_sort)
    else:
        nlf_reg = nlf_v
        nlf_i_sort = np.sort(nlf_i)
    
    v = np.concatenate(([nlf_reg[0]], nlf_reg, [nlf_reg[-1]]))
    x = np.concatenate(([0], nlf_i_sort, [1]))
    var_nlf = np.interp(np.arange(0, 256)/255.0, x, v)*sigma_p*sigma_p

    return [sigma_p, sigma_o, var_nlf]
