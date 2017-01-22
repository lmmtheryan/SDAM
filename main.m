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
    RGB_n = imnoise(RGB,'gaussian',0, 0.5);
    imwrite(RGB_n,['./samples/t00' num2str(k) '.jpg'])
    input(:,k)=RGB_n(:);
    subplot(3,param_g.P,k+2*param_g.P),imshow(RGB_n);
    
%     RGB_i=RGB;
%     [rows cols numberOfColors] = size(RGB_i);
%     row_start=uint(rand*rows/2);
%     col_start=uint(rand*cols/2);
%     RGB_i(row_start:row_start+rows/2,col_start:col_start+cols/2, 1) = 0;
%     RGB_i(row_start:row_start+rows/2,col_start:col_start+cols/2, 2) = 0;
%     RGB_i(row_start:row_start+rows/2,col_start:col_start+cols/2, 3) = 0;
%     imwrite(RGB_i,['./samples/ic00' num2str(k) '.jpg'])
%     input(:,k)=RGB_i(:);
%     subplot(3,param_g.P,k+2*param_g.P),imshow(RGB_i);

end
pattern=double(pattern);

input=double(input);


%% RNN
T=0.02;
Tmax=5;
K1=10000;
K2=2000;
RGBsize=size(RGB);
param_U.sigma=1000;
param_U.sigma2=1000;

w=1.5;
fs=30;

for i=1:1
pattern_num=3;
x=input(:,pattern_num);
param_U.K=K1/ norm(dUa_func(x,pattern,S,param_g,param_U));
h=zeros(size(x));
err_norm1=zeros(Tmax/T+1,1);
err_norm2=zeros(Tmax/T+1,1);

for t=0:Tmax/T
    if mod(t,1/T)==0
        figure
        imshow(reshape(uint8(x),size(RGB)));
    end
        
    t*T
    err_norm1(t+1,1)=(norm(x-pattern(:,pattern_num))/norm(pattern(:,pattern_num)))^2;
%     W=(x-h-param_U.K.*dUa_func( x,pattern,S,param_g,param_U))*pinv(threshold(x,0));
%     x=x+T*dotx_func(x,W,h);
    x=x-T*(-x+h+x-h-param_U.K*dUa_func(x,pattern,S,param_g,param_U));
    param_U.K=K1/ norm(dUa_func(x,pattern,S,param_g,param_U));
end
err_norm1(Tmax/T+1,1)=(norm(x-pattern(:,pattern_num))/norm(pattern(:,pattern_num)))^2;

figure
imshow(reshape(uint8(x),size(RGB)));


t=0:T:Tmax;
figure
plot(t,err_norm1','LineWidth',w)
xlabel('time (s)','fontsize',fs)
legend('NMSE','Location','East')
set(gca,'LineWidth',w,'fontsize',fs)
end

% [x,err_norm2]=second_stage(x,pattern,param_g,param_U,K2,10,pattern_num,h);
% 
% figure
% imshow(reshape(uint8(x),size(RGB)));
% 
% figure
% t=0:T:Tmax;
% plot(t,err_norm2')






