function [diff_array1,diff_array2,diff_array3]=test_rot(i1,i2)

size_i1=size(i1.img);
im_center1 = (size_i1+1)./2;

% Definition
angle=-35:5:35;
diff_array1=zeros(1,length(angle));
diff_array2=zeros(1,length(angle));
diff_array3=zeros(1,length(angle));

% Rotation + Cost function value computation
for i = 1:length(angle)
    Tr = makeTransf_3D_center(0,0,0,0,0,angle(i),1,1,1,im_center1);
    diff_array1(i)=compare_images(i1,i2,Tr,'Abs_Diff');
    diff_array2(i)=compare_images(i1,i2,Tr,'MI');
    diff_array3(i)=compare_images(i1,i2,Tr,'SSD');
end

% Generate plots
figure
plot(angle, diff_array1, 'b');
xlabel('Angle (º)')
ylabel('Sum of Absolute Differences')

figure
plot(angle, diff_array2, 'g');
xlabel('Angle (º)')
ylabel('Mutual Information')

figure
plot(angle, diff_array3, 'r');
xlabel('Angle (º)')
ylabel('SSD')

end
