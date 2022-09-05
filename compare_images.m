function diff=compare_images(i1,i2,Tr_Mat,costF)

% This function takes two images (i1 and i2) and compares i1 to a transformed version
% of i2 applying Tr_M transformation Matrix

i2_Tr = transform_image_3D(Tr_Mat,single(i2.img), 'linear');

i1_256=uint8(255*mat2gray(i1.img));
i2_256=uint8(255*mat2gray(i2_Tr));
i1_256_double=double(255*mat2gray(i1.img));
i2_256_double=double(255*mat2gray(i2_Tr));
sz=size(i1_256);
N=sz(1)*sz(2)*sz(3); %Number of pixels

switch costF
    case 'SSD'
        % Compute sum of squared differences
        aux_diff = (i1_256_double-i2_256_double).^2;
        diff = (1/N)*sum(aux_diff(:));
    case 'Abs_Diff'
        % Compute absolute differences
        aux_diff = abs(i1_256_double-i2_256_double);
        diff = (1/N)*sum(aux_diff(:));
    case 'MI'
        % Compute joint histogram
        H = spm_hist2(i1_256,i2_256, eye(4) ,[1 1 1]);
        
        % Compute cost function from histogram
        H  = H+eps;
        H  = H/sum(H(:)); % normalization
        s1 = sum(H,1); % marginal probability image 1
        s2 = sum(H,2); % marginal probability image 2
        
        %  Compute mutual Information:
        H_A = -sum(s1.*log2(s1));
        H_B = -sum(s2.*log2(s2));
        H_AB = -sum(sum(H.*log2(H)));
		diff  = H_A + H_B - H_AB;
        figure (1)
        subplot(3,1,1);
        imshow(i1_256(:,:,round(sz(3)/2)),[]);
        title('MRI')
        subplot(3,1,2);
        imshow(i2_256(:,:,round(sz(3)/2)),[]);
        title('PET')
        subplot(3,1,3);
        imshow(log(H),[]);
        title('Log Joint Histogram')
        
        
    otherwise
        diff=0;
end

end
