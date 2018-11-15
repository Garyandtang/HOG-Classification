%The EIE4100 Assignment
%Author: Jiawei Tang
clear;clc;
nr_b=100; %number of blocks in a row
nc_b=100; %number of blocks in a column
nbin=9; %number of orientation bins
distance_metric='L2-metric'; %L1-metric L2-metric Chi-square

%calculate the HOG feature of all training images
training_set = zeros(25, nr_b*nc_b*nbin);
for class_no = 1:5
    for image_no = 1:5
        filepath=strcat('../Images/Images/',num2str(class_no), '/', num2str(class_no), num2str(image_no), '_Training.bmp'); 
        I = imread(filepath);
        training_set(5*(class_no-1)+image_no, :) = Image2HoG(I,nr_b, nc_b, nbin);
    end
end
%calculate the HoG of all testing images
testing_set = zeros(25, nr_b*nc_b*nbin);
for class_no = 1:5
    for image_no = 1:5
        filepath=strcat('../Images/Images/',num2str(class_no), '/', num2str(class_no), num2str(image_no), '_Test.bmp'); 
        I = imread(filepath);
        testing_set(5*(class_no-1)+image_no, :) = Image2HoG(I,nr_b, nc_b, nbin);
    end
end
%classficate all test images based on the the distance of HOG features
counter = 0;
distance_min = 10000000;
for i = 1:25            %indicate the testing set
    %get the label of testing set
    if mod(i,5)==0
        class_label = i/5;
    else
        class_label = floor(i/5)+1;
    end
    %fprintf(strcat(num2str(class_label),'\n'));
    for j = 1:25        %indicate the training set
        %use different distance metric to calculate the distance
        if strcmpi(distance_metric, 'L2-metric')
            d = sum((training_set(j, :)-testing_set(i,:)).^2);
        elseif strcmpi(distance_metric, 'Chi-square')
            d = sum(((training_set(j, :)-testing_set(i,:)).^2)./(training_set(j, :) + testing_set(i,:)));
        else
            d = sum(abs((training_set(j,:)-testing_set(i,:)))); 
        end
        %fprintf(strcat(num2str(d),'\n'));
        %get predicted class of the testing image based on the minimum HOG distance
        if d < distance_min
            if mod(j,5)==0
                predict_class = j/5;
            else
                predict_class = floor(j/5)+1;
            end
            distance_min = d;
        end
    end
    %reset the minimum distance
    distance_min = 10000000;
    %count the correct prediction
    if class_label == predict_class
        counter = counter + 1;
    end
end
fprintf(strcat('The accuracy is ',num2str(counter/25),'\n'));