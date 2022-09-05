% Example code
close all
clear all
clc

%% Define image names
file1='.\Images\MR.nii';
file2='.\Images\PET.nii';

%% Load images using Nifty reader
im1=load_nii(file1);
im2=load_nii(file2);

%% Test rotation/translation
[d1,d2,d3]=test_rot(im1,im2);