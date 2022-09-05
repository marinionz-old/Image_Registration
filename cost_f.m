function diff=cost_f(p,i1_256_in,i2_256_in, samp)

global p_total samp
    
    % A permutation is needed between rows and columns because spm_hist2
    % function works different than Matlab (it reads columns first)
    i1_256=permute(i1_256_in,[2,1,3]);
    i2_256=permute(i2_256_in,[2,1,3]);

    size_i1=size(i1_256);
    im_center1 = (size_i1+1)./2;
    
    disp(' ')
    disp(['Transformation: ', num2str(p')])
	Tr = makeTransf_3D_center(p(1),p(2),p(3),p(4),p(5),p(6),1.0,1.0,1.0,im_center1);
    
    H = spm_hist2(i1_256,i2_256, Tr ,samp);

    % Smooth the histogram
    fwhm = [7 7];
    lim  = ceil(2*fwhm);
    krn1 = spm_smoothkern(fwhm(1),-lim(1):lim(1)) ; 
    krn1 = krn1/sum(krn1);
    H = conv2(H,krn1);
    krn2 = spm_smoothkern(fwhm(2),-lim(2):lim(2))';
    krn2 = krn2/sum(krn2);
    H = conv2(H,krn2);
    
    % Compute cost function from histogram
    H  = H+eps;
    Hnorm  = H/sum(H,'all');
    s1 = sum(Hnorm,1); % marginal probability image 1
    s2 = sum(Hnorm,2); % marginal probability image 2
    
    %  Compute mutual Information:
    H_A = -sum((s1).*log2(s1));
    H_B = -sum((s2).*log2(s2));
    H_AB = -sum(sum(Hnorm'.*log2(Hnorm')));
    diff  = H_A + H_B - H_AB;
    
    %     % The sign of the Mutual Information is changed because spm_powell
    %     % will minimize the value, so it should be negative
    diff  = -diff;
    disp(['Minus H: ', num2str(diff)])
    
    [x,y]=size(p_total);
    p_total(x+1,:)=p;

end
