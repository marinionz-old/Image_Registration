% Example code for registration
close all
clear all
clc
global p_total samp

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

% Standard: (10,10,5,-10,-10,-10,1,1,1)
Tr_Mat = makeTransf_3D_center(10,10,5,-50,-10,-10,1,1,1,im_center2); % 
i2_Transf = transform_image_3D(Tr_Mat,single(i2_256), 'linear');
i2_Transf_256 = uint8(255*mat2gray(i2_Transf));

%% OPTIMIZATION
% The following lines will perform the registration step. The following 
% parameteres will initialize the optimization. We don't have an initial 
% guess of the transformation, so they are zero (no rotations and no translations)
params_ini = [0 0 0 0 0 0]; % initial parameters
p_total(1,:)=params_ini;
p_final_first_step=params_ini;
samp = [4 4 4];
tic
[p_final_first_step,f_value_first_step] = spm_powell(params_ini,eye(6),0.001,'cost_f',i1_256,i2_Transf_256, samp); % powell optimizer

% We introduce multiresolution thanks to inputing the output of the 4x4x4
% analysis as initialization parameters for a 2x2x2 optimization analysis.
samp = [2 2 2];
[p_final,f_value] = spm_powell(p_final_first_step,eye(6),0.001,'cost_f',i1_256,i2_Transf_256, samp); % powell optimizer
toc

%% DISPLAY REGISTRATION RESULT
disp(' ')
disp(['Transformation (FINAL): ', num2str(p_final')])
disp(['Minus H (FINAL): ', num2str(f_value)])

%% APPLY REGISTRATION RESULT
% The following lines will apply the transformation found in the registration step
Tr_Mat2 = makeTransf_3D_center(p_final(1),p_final(2),p_final(3),p_final(4),p_final(5),p_final(6),1,1,1,im_center2);
i2_Transf_TransfBack = transform_image_3D(inv(Tr_Mat2),single(i2_Transf_256), 'linear');
i2_Transf_TransfBack_256 = uint8(255*mat2gray(i2_Transf_TransfBack));

% Display
figure
subplot(2,2,1), imshow(squeeze(i1_256(:,:,floor(im_center1(3)))),[])
subplot(2,2,1), title('Image 1 (T1)')
subplot(2,2,2), imshow(squeeze(i2_Transf_256(:,:,floor(im_center2(3)))),[])
subplot(2,2,2), title('Image 2 (T2): Not registered')
subplot(2,2,3:4), imshow(squeeze(i2_Transf_TransfBack_256(:,:,floor(im_center2(3)))),[])
subplot(2,2,3:4), title('Image 2 registered')

figure
[dim,aux]=size(p_total);
iter=1:dim;
hold on; axis tight
plot(iter,p_total(:,1),'b-',iter,p_total(:,2),'r-',iter,p_total(:,3),'g-', ...
    iter,p_total(:,4),'y--',iter,p_total(:,5),'k--',iter,p_total(:,6),'m--');
xlabel('Iterations'), ylabel('Matrix parameter value')
title('Registration parameters evolution through iterations')
legend('Tx','Ty','Tz','Rx','Ry','Rz');
