close all; clear; clc;


%%
% rgb = imread('./src/couple.tiff');
rgb = imread('./src/female.tiff');
cie = CIE_HP_Naik(rgb);
imshow(cie)
