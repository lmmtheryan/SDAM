% Saliency detection Demo
% [HISTORY]
% Nov 23, 2011 : created by Hae Jong Seo

close all;
clear all;
clc;

% Global parameter

param_g.P = 10; %number of patterns
param_g.NI = 10; %number of noised input

% parameters for global self-resemblance

param_sal.P = 3; % LARK window size
param_sal.alpha = 0.42; % LARK sensitivity parameter
param_sal.h = 0.2; % smoothing parameter for LARK
param_sal.L = 7; % # of LARK in the feature matrix 
param_sal.N = inf; % size of a center + surrounding region for computing self-resemblance
param_sal.sigma = 0.07; % fall-off parameter for self-resemblamnce. **For visual purpose, use 0.2 instead of 0.06**
param_sal.omega = 1;

%% Compute Saliency Weight Matrix using the given patterns
figure(1)
for k = 1:param_g.P
    FN = ['./samples/p00' num2str(k) '.jpg'];
    RGB = imread(FN);
    pattern(:,k)=RGB(:);
    S1 = SalWeight(RGB,[64 64],param_sal); % Resize input images to [64 64]
    % Plot saliency maps
    S2 = imresize(mat2gray(S1),[size(RGB,1), size(RGB,2)],'bilinear');
    Smax=max(max(S2));
    S3=(S2+param_sal.omega)/(Smax+param_sal.omega);
    subplot(3,param_g.P,k),sc(RGB);    
    subplot(3,param_g.P,k+param_g.P),sc(cat(3,S3,double(RGB(:,:,1))),'prob_jet');
    S4=S3(:);
    S(:,k)=double([S4;S4;S4]);
%     RGB_n = imnoise(RGB,'salt & pepper', 0.75);
%     imwrite(RGB_n,['./samples/t00' num2str(k) '.jpg'])
%     input(:,k)=RGB_n(:);
%     subplot(3,param_g.P,k+2*param_g.P),imshow(RGB_n);
    
    RGB_i=RGB;
    [rows cols numberOfColors] = size(RGB_i);
    row_start=uint8(rand*rows/2);
    col_start=uint8(rand*cols/2);
    RGB_i(row_start:uint8(row_start+rows/2),col_start:uint8(col_start+cols/2), 1) = 0;
    RGB_i(row_start:uint8(row_start+rows/2),col_start:uint8(col_start+cols/2), 2) = 0;
    RGB_i(row_start:uint8(row_start+rows/2),col_start:uint8(col_start+cols/2), 3) = 0;
    imwrite(RGB_i,['./samples/ic00' num2str(k) '.jpg'])
    input(:,k)=RGB_i(:);
    subplot(3,param_g.P,k+2*param_g.P),imshow(RGB_i);

end
pattern=double(pattern);
pattern_in=pattern;
pattern_out=zeros(size(pattern));

pattern_out(:,1)=pattern(:,1);
pattern_out(:,2)=pattern(:,2);
pattern_out(:,3)=pattern(:,8);
pattern_out(:,4)=pattern(:,8);
pattern_out(:,5)=pattern(:,8);
pattern_out(:,6)=pattern(:,8);
pattern_out(:,7)=pattern(:,1);
pattern_out(:,8)=pattern(:,8);
pattern_out(:,9)=pattern(:,2);
pattern_out(:,10)=pattern(:,8);
input=double(input);


%% RNN
T=0.005;
Tmax=5;
K1=10000;
K2=2000;
RGBsize=size(RGB);

for i=1:param_g.P
pattern_num=i;

param_U.sigma=1000;
K1=10000;
x=input(:,pattern_num);
param_U.K=K1/ norm(dUa_func(x,pattern_in,S,param_g,param_U));
h=zeros(size(x));


Tmax=3;
err_norm1=zeros(Tmax/T+1,1);

for t=0:Tmax/T
    t*T
    err_norm1(t+1,1)=(norm(x-pattern_in(:,pattern_num))/norm(pattern_in(:,pattern_num)))^2;
%     W=(x-h-param_U.K.*dUa_func( x,pattern,S,param_g,param_U))*pinv(threshold(x,0));
%     x=x+T*dotx_func(x,W,h);
    x=x-T*(-x+h+x-h-param_U.K*dUa_func(x,pattern_in,S,param_g,param_U));
    param_U.K=K1/ norm(dUa_func(x,pattern_in,S,param_g,param_U));
end
err_norm1(Tmax/T+1,1)=(norm(x-pattern(:,pattern_num))/norm(pattern(:,pattern_num)))^2;
x0=x;
% figure
% imshow(reshape(uint8(x),size(RGB)));
% 
% figure
% t=0:T:Tmax;
% figure
% plot(t,err_norm1')

Tmax=1.5;
K1=50000;
kh=0.01;
param_U.sigma=10000;
Wh=Wh_func(x, pattern_in ,kh );
param_U.K=K1/ norm(dUd_func(x,Wh,pattern_out,param_g,param_U));
h=zeros(size(x));
err_norm2=zeros(Tmax/T+1,1);



for t=0:Tmax/T
    t*T
    err_norm2(t+1,1)=(norm(x-pattern_out(:,pattern_num))/norm(pattern_out(:,pattern_num)))^2;
%     W=(x-h-param_U.K.*dUa_func( x,pattern,S,param_g,param_U))*pinv(threshold(x,0));
%     x=x+T*dotx_func(x,W,h);
    x=x-T*(-x+h+x-h-param_U.K*dUd_func(x,Wh,pattern_out,param_g,param_U));
    param_U.K=K1/ norm(dUd_func(x,Wh,pattern_out,param_g,param_U));
end
err_norm2(Tmax/T+1,1)=(norm(x-pattern_out(:,pattern_num))/norm(pattern_out(:,pattern_num)))^2;

figure
imshow(reshape(uint8(x),size(RGB)));


t=0:T:Tmax;
figure
plot(t,err_norm2')
end

% [x,err_norm2]=second_stage(x,pattern,param_g,param_U,K2,10,pattern_num,h);
% 
% figure
% imshow(reshape(uint8(x),size(RGB)));
% 
% figure
% t=0:T:Tmax;
% plot(t,err_norm2')






