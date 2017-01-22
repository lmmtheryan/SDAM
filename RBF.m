function [ S ] = RBF( Z, Mu,variance )
%RBF Summary of this function goes here
%   Detailed explanation goes here
S=-exp(-(Z-Mu)'*(Z-Mu)/variance);

