% Example code for registration
close all
clear all
clc

addpath(genpath('C:\Users\marti\Desktop\2019-2020\2 cuatri\Advanced topics in medical image\Homeworks\Homework_Image_Registration'));

%% Load images
file1='.\Images\Study003_MR_T1.nii';
im1 = load_nii(file1);
i1_256 = uint8(255*mat2gray(im1.img));
size_i1 = size(i1_256);
im_center1 = (size_i1+1)./2;

file2='.\Images\Study003_MR_T2.nii';
im2 = load_nii(file2);
i2_256=uint8(255*mat2gray(im2.img));
size_i2=size(im2.img);
im_center2 = (size_i2+1)./2;

%% DEFINE TRANSFORMATION PARAMETERS
% The following line specifies the transformation that will be applied to
% image2. The registration algorithm will try to find the parameters that
% we have used to transform the algorithm.
% The first 3 parameters are rotations in degrees, the next 3 are
% translations and then three scalings (all 1.0)
Tr_Mat = makeTransf_3D_center(20,10,5,-10,-10,10,1,1,1,im_center2); % MODIFY THIS LINE TO TEST DIFFERENT TRANSFORMATIONS
i2_Transf = transform_image_3D(Tr_Mat,single(i2_256), 'linear');
i2_Transf_256 = uint8(255*mat2gray(i2_Transf));

%% OPTIMIZATION
% The following lines will perform the registration step. The following 
% parameteres will initialize the optimization. We don't have an initial 
% guess of the transformation, so they are zero (no rotations and no translations)
p = [0 0 0 0 0 0]; % initial parameters
samp = [2 2 2]; % We may try it with different parameters

i1_256_in=i1_256;
i2_256_in=i2_Transf_256;
   
%% Cost function starts

% A permutation is needed between rows and columns because spm_hist2
    % function works different than Matlab (it reads columns first)
    i1_256pix=permute(i1_256_in,[2,1,3]);
    i2_256pix=permute(i2_256_in,[2,1,3]);

    size_i1=size(i1_256pix);
    im_center1 = (size_i1+1)./2;
    
    disp(' ')
    disp(['Transformation: ', num2str(p)])
	Tr = makeTransf_3D_center(p(1),p(2),p(3),p(4),p(5),p(6),1.0,1.0,1.0,im_center1);
    
    H = spm_hist2(i1_256pix,i2_256pix, Tr ,samp);

    % Smooth the histogram
    fwhm = [7 7];
    lim  = ceil(2*fwhm);
    krn1 = spm_smoothkern(fwhm(1),-lim(1):lim(1)) ; 
    krn1 = krn1/sum(krn1); 
    H = conv2(H,krn1);
    krn2 = spm_smoothkern(fwhm(2),-lim(2):lim(2))'; 
    krn2 = krn2/sum(krn2); 
    H = conv2(H,krn2);

    %%
%     % Compute cost function from histogram
      H  = H+eps;
      Hnorm  = H/sum(H,'all');
      s1 = sum(Hnorm,1); % marginal probability image 1
      s2 = sum(Hnorm,2); % marginal probability image 2
            
    %  Compute mutual Information:
     H_A = -sum(s1.*log2(s1));
     H_B = -sum(s2.*log2(s2));
     H_AB = -sum(sum(Hnorm'.*log2(Hnorm')));
     diff  = H_A + H_B - H_AB;

%     % The sign of the Mutual Information is changed because spm_powell
%     % will minimize the value, so it should be negative
     diff  = -diff;
     disp(['Minus H: ', num2str(diff)])
