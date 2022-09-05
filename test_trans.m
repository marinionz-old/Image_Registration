function [diff_array1,diff_array2,diff_array3]=test_trans(i1,i2)

size_i1=size(i1.img);
im_center1 = (size_i1+1)./2;

% Definition
trans=-12:2:12;
diff_array1=zeros(1,length(trans));
diff_array2=zeros(1,length(trans));
diff_array3=zeros(1,length(trans));

% Rotation + Cost function value computation
for i = 1:length(trans)
    Tr = makeTransf_3D_center(trans(i),0,0,0,0,0,1,1,1,im_center1);
    diff_array1(i)=compare_images(i1,i2,Tr,'Abs_Diff');
    diff_array2(i)=compare_images(i1,i2,Tr,'MI');
    diff_array3(i)=compare_images(i1,i2,Tr,'SSD');
end

% Generate plots
figure
plot(trans, diff_array1, 'b');
xlabel('Angle (º)')
ylabel('Sum of Absolute Differences')

figure
plot(trans, diff_array2, 'g');
xlabel('Angle (º)')
ylabel('Mutual Information')

figure
plot(trans, diff_array3, 'r');
xlabel('Angle (º)')
ylabel('SSD')

end
