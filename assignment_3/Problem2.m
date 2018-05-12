clear all
close all

I = double(imread('./peppers_color.tif'));
k = 3;


[rows, cols, c]=size(I);
N = rows*cols;
img_r = I(:,:,1); 
img_g = I(:,:,2);
img_b = ones(rows, cols)*128;
[cy,cx] = ind2sub([rows, cols], 1:N);

img_r = img_r/255;
img_g = img_g/255;
img_b = img_b/255;
cy = cy/rows;
cx = cx/cols;

raw = zeros(N, 3);
raw(:,1) = img_r(:);
raw(:,2) = img_g(:);
raw(:,3) = img_b(:);

[p, u, v]=em(raw, k);



imgRe=zeros(N,3);
% kColor=jet(k);
kColor=u(:,1:3);
imgRe=p*kColor;

figure;
for i = 1:k
    seg_i(:, :) = reshape(p(:, i), [rows, cols]);
    subplot(1, k, i);
    imshow(seg_i);
end

maskOut=zeros(rows,cols,3);
% maskOut(:,:,3) = ones(rows, cols)*128;
for i = 1:2
    maskOut(:,:,i)=reshape(imgRe(:,i),[rows,cols]);
end

figure; imshow(rgb2gray(maskOut)), colormap(gray);
title('based on k Gaussian by EM algorithm on color space')

 function [p, u, v] = em(raw, k)
    % The output is p, which is assignment matrix.its [ii,jj]th element means
    % the probability that Xii is generated by jjth Gaussian function.

    [n, dim]=size(raw);
    rand_temp = randi([1, n], k, 1);
    u = raw(rand_temp,:);

    v = zeros(k,1);
    for ii = 1:k
        raw_tmp = raw(ii:k:end,1);
        v(ii,:) = std(raw_tmp);
    end

    w = ones(k,1)/k;
    p = zeros(n,k);
    u_t = u*0;
    v_t = 0*v;
    w_t = w*0;
    energy = sum(sum((u-u_t).^2))+sum(sum((v-v_t).^2))+(sum((w-w_t).^2));
    iteration = 1;
    x_u = zeros(size(raw));
    while energy>10^(-6)
        for jj=1:k
            for ss=1:dim
                x_u(:,ss)=raw(:,ss)-u(jj,ss)*ones(n,1);
            end
            x_u=x_u.*x_u;
            p(:,jj)=power(sqrt(2*pi)*v(jj),-1*dim)*exp((-1/2)*sum(x_u,2)./(v(jj).^2));
            p(:,jj)=p(:,jj)*w(jj);

        end
        p_sum = sum(p,2);
        for jj=1:k
            p(:,jj)=p(:,jj)./p_sum;
        end

        p_sum_2 = sum(p,1);
        pNorm = p*0;
        for jj=1:k
            pNorm(:,jj) = p(:,jj)/p_sum_2(jj);
        end

        u_t = u;
        v_t = v;
        w_t = w;
        u=(pNorm.')*raw;

        for jj=1:k
            for ss=1:dim
                x_u(:,ss)=raw(:,ss)-u(jj,ss)*ones(n,1);
            end
            x_u=x_u.*x_u;
            x_uSum=sum(x_u,2);
            v(jj)=sqrt(1/dim*(pNorm(:,jj).')*x_uSum);
        end

        w=(sum(p)/n).';
%         disp(sprintf(['iteration=',num2str(iteration),'; energy=',num2str(energy,'%g')]))
        iteration=iteration+1;
        energy=sum(sum((u-u_t).^2))+sum(sum((v-v_t).^2))+(sum((w-w_t).^2));


    end
   

 end





