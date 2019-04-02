function i_out = bilateralflt(img_in,var_n,radius,sigma_s)

img_or = img_in;
i_out = 0;
P = 0;

[rows, cols] = size(img_in);
img_in = padarray(img_in,[radius radius],'symmetric');

[dx, dy] = meshgrid(-radius:radius);
h = exp(- (dx.^2 + dy.^2) / (2 * sigma_s^2));

for x = -radius:radius
    for y = -radius:radius
        
        X = img_in(1+radius+y:rows+radius+y,1+radius+x:cols+radius+x);
        delta =  X  - img_or;
        pN =h(y+radius+1,x+radius+1)*exp(-delta.*delta/(2*var_n));
        i_out = i_out + pN.*X;
        P = P+ pN;              
        
    end
end

i_out = i_out./P;

