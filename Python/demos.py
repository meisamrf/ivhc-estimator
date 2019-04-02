# demo for image noise estimation (processed, signal-dependent and AWGN)

import numpy as np
from imnest_ivhc import imnest_ivhc
import skimage.io
import skimage.filters
import matplotlib.pyplot as plt


def bilateral_flt(img_in, var_n, radius, sigma_s):

    img_or = img_in
    i_out = 0
    P = 0

    (rows, cols) = img_in.shape
    img_in = np.pad(img_in, (radius, radius),'reflect')
    ar = np.arange(-radius, radius+1, 1)

    [dx, dy] = np.meshgrid(ar, ar)
    h = np.exp(- (dx**2 + dy**2) / (2 * sigma_s**2))

    for y in ar:
        for x in ar:
      
            X = img_in[radius+y:rows+radius+y,radius+x:cols+radius+x]
            delta =  X  - img_or
            pN =h[y+radius,x+radius]*np.exp(-delta*delta/(2*var_n))
            i_out = i_out + pN*X
            P = P+ pN

    i_out = i_out/P

    return i_out

def demo_ppn_iso():
    # demo for estimation of frequency-dependent (Processed) image noise
    print('----- Isotropic spatially correlated noise -----')

    np.random.seed(0)
    img = skimage.io.imread('./img/peppers.png')

    for sigma_a in [10, 15]:
        for sigma_GB in [0.45, 0.5, 0.55]:
            noise = sigma_a*np.random.randn(img.shape[0], img.shape[1])
            noise = skimage.filters.gaussian(noise, sigma=sigma_GB, mode='reflect')
            noise_std = np.std(noise)
            im_n = np.float32(img) + np.float32(noise)
            [est_sigma_p, est_sigma_o, nlf] = imnest_ivhc(im_n, 0)
            est_error = np.abs(noise_std-est_sigma_p)
            est_error = abs(noise_std-est_sigma_p)
            est_gamma = est_sigma_o/est_sigma_p
            print('------------------------')
            print('sigma_GB = %2.3f, sigma_a = %2.3f, sigma_n = %2.3f'%(sigma_GB,sigma_a,noise_std))
            print('Noise std estimation error: %2.3f'%(est_error))
            print('Estimated processing degree: %2.3f'%(est_gamma))
            print('------------------------')


def demo_ppn_aniso():
    # demo for estimation of frequency-dependent (Processed) image noise
    print('----- Anisotropic spatially correlated noise -----')

    np.random.seed(0)
    img = skimage.io.imread('./img/peppers.png')

    for sigma_a in [10, 15]:
        for scale in [0.5, 1, 2]:
            noise = sigma_a*np.random.randn(img.shape[0], img.shape[1])
            noise = bilateral_flt(noise, sigma_a*sigma_a*scale, 1, 1)
            noise_std = np.std(noise)
            im_n = np.float32(img) + np.float32(noise)
            [est_sigma_p, est_sigma_o, nlf] = imnest_ivhc(im_n, 0)
            est_error = np.abs(noise_std-est_sigma_p)
            est_error = abs(noise_std-est_sigma_p)
            est_gamma = est_sigma_o/est_sigma_p
            print('------------------------')
            print('sigma_BL = %2.3f, sigma_a = %2.3f, sigma_n = %2.3f'%(sigma_a*scale,sigma_a,noise_std))
            print('Noise std estimation error: %2.3f'%(est_error))
            print('Estimated processing degree: %2.3f'%(est_gamma))
            print('------------------------')


def demo_awgn():
# demo for estimation of image noise (AWGN)
    np.random.seed(0)
    img = skimage.io.imread('./img/kodim04.png')

    print('----- Synthetic AWGN -----')

    for sigma_a in [5, 10, 15]:
        noise = sigma_a*np.random.randn(img.shape[0], img.shape[1])
        noise_std = np.std(noise)
        im_n = np.float32(img) + np.float32(noise)
        [est_sigma_p, est_sigma_o, nlf] = imnest_ivhc(im_n, 0)
        est_error = np.abs(noise_std-est_sigma_p)
        print('------------------------')
        print('sigma_a = %2.3f, sigma_n =  %2.3f '%(sigma_a, noise_std))
        print('Noise std estimation error: %2.3f %%'%(100*est_error/noise_std))
        print('------------------------')

def demo_pgn():

    # demo for estimation of signal-dependent (mixed Possionian-Gaussian) image noise
    np.random.seed(0)
    img = skimage.io.imread('./img/sample1.png')
    # generate signal-dependent noise
    sigma_noise = 8
    nlf_sqrt = sigma_noise*(.4+np.arange(0, 256)/255.0)
    nlf = nlf_sqrt**2
    noise = np.random.randn(img.shape[0], img.shape[1])*nlf_sqrt[np.int32(img)]
    # generate noisy image
    im_n = np.float32(img) + np.float32(noise)

    [est_sigma_p, est_sigma_o, est_var_nlf] = imnest_ivhc(im_n)

    im_n[im_n<0] = 0
    im_n[im_n>255] = 255
    plt.imshow(np.uint8(im_n))
    plt.show()

    plt.plot(est_var_nlf)
    plt.plot(nlf,'r')
    plt.show()

    rmse_var = np.sqrt(np.mean((est_var_nlf-nlf)**2))
    maxe_var = np.max(np.abs(est_var_nlf-nlf))

    print('RMSE of estimated noise variance: %2.3f'%(rmse_var))
    print('Max error of estimated noise variance: %2.3f'%(maxe_var))


    rmse_std = np.sqrt(np.mean((np.sqrt(est_var_nlf)-np.sqrt(nlf))**2))
    maxe_std = np.max(np.abs(np.sqrt(est_var_nlf)-np.sqrt(nlf)))

    print('RMSE of estimated standard deviation: %2.3f'%(rmse_std))
    print('Max error of estimated standard deviation: %2.3f'%(maxe_std))




def main():

    print('*********** demo AWGN **********')
    demo_awgn()

    print('*********** demo PGN **********')
    demo_pgn()

    print('*********** demo PPN ISO **********')
    demo_ppn_iso()

    print('*********** demo PPN ANISO **********')
    demo_ppn_aniso()

if __name__ == "__main__":
    main()
