function [x] = rms(a_X)
%% Project Title: Brain Tumor Tissue Detection Project

[rows cols] 	= size(a_X);
N		= rows * cols;

S		= sum(sum(a_X.^2));
x		= sqrt(S/N);