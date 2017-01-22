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
    subplot(3,4,k)
    sc(cat(3,S3,double(RGB(:,:,1))),'prob_jet');
    S4=S3(:);
    S(:,k)=double([S4;S4;S4]);
%     RGB_n = imnoise(RGB,'speckle', 0.5);
%     imwrite(RGB_n,['./samples/t00' num2str(k) '.jpg'])

end






