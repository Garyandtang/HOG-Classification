nclass=5;
nimage=5;

nr_b=6; %number of blocks in a row
nc_b=6; %number of blocks in a column
nbin=9; %number of orientation bins
dist_metric='Chi-square'; %distance metric, could be 'L1-metric' (Default), 'L2-metric' or 'Chi-square'

main(nclass, nimage, nr_b, nc_b, nbin, dist_metric);

function main(nclass, nimage, nr_b, nc_b, nbin, dist_metric)
    dataset=zeros(nclass*nimage,nbin*nr_b*nc_b);
    for class_no = 1:nclass
        for image_no = 1:nimage
            filepath=strcat(num2str(class_no), '/', num2str(class_no), num2str(image_no), '_Training.bmp'); % The '/' should be changed to '\' on Windows
            I = imread(filepath);
        
            dataset(class_no*nimage+image_no-nimage, :)=Image2HoG(I, nr_b, nc_b, nbin);
        end
    end
    correct=0; % Number of correct classifications
    for class_no= 1:nclass
        for image_no=1:nimage
            filepath=strcat(num2str(class_no), '/', num2str(class_no), num2str(image_no), '_Test.bmp'); % The '/' should be changed to '\' on Windows
            I=imread(filepath);
            Image_HoG=Image2HoG(I, nr_b, nc_b, nbin);
            distance=zeros(nclass*nimage);
            for m=1:nclass
                for n=1:nimage
                    if strcmpi(dist_metric, 'L2-metric')
                        d=(dataset(m*nimage+n-nimage, :)-Image_HoG).^2;
                    elseif strcmpi(dist_metric, 'Chi-square')
                        d=((dataset(m*nimage+n-nimage, :)-Image_HoG).^2)./(dataset(m*nimage+n-nimage, :) + Image_HoG);
                    else
                        dist_metric = 'L1-metric';
                        d=abs(dataset(m*nimage+n-nimage, :) - Image_HoG);
                    end
                    distance(m*nimage+n-nimage) = sum(d);
                end
            end
            
            min_dist=distance(1);
            class=1;
            for m=1:nclass
                for n=1:nimage
                    if distance(m*nimage+n-nimage) < min_dist
                        class=m;
                        min_dist=distance(m*nimage + n - nimage);
                    end
                end
            end
            
            
            if class == class_no
                correct = correct + 1;
            end
        end
    end
    disp('Using:');
    disp(strcat('nc_b = ',num2str(nc_b),','));
    disp(strcat('nr_b = ',num2str(nr_b),','));
    disp(strcat('nbin = ',num2str(nbin),' and'));
    disp(strcat('distance metric: ',dist_metric));
    disp(strcat('The accuracy is ', num2str(correct), '/', num2str(nclass*nimage), ' = ', num2str(correct/(nclass*nimage)), '.'));
end

function [ghist] = HoG1(Im, Ip, nbin)
    %Compute the HoG of an image block, with unsigned gradient
    %Im: magnitude
    %Ip: orientation
    %nbin: number of bins
    
    ghist = zeros(1,nbin);
    [nr1 nc1]=size(Im);
    %Compute HoG
    interval= 180/nbin;
    for i= 1:nr1
        for j=1:nc1
            index=floor(Ip(i,j)/interval)+1;
            ghist(index)=ghist(index)+Im(i,j);
        end
    end
end

function [nhist] = Histogram_Normalization(ihist)
    %Normalize input histogram ihist to a unit histogram
    total_sum = sum(ihist);
    nhist = ihist/total_sum;
end

function [Image_HoG] = Image2HoG(I,nr_b,nc_b,nbin)
    %Generate feature vectors from the input image
    Sx=[-1 0 1; -2 0 2; -1 0 1];
    Sy=[-1 -2 -1; 0 0 0; 1 2 1];
    [nr nc]=size(I);
    %Gradient Magnitude and Orientation
    Ix=imfilter(double(I), Sx);
    Iy=imfilter(double(I), Sy);
    I_mag=sqrt(Ix.^2+Iy.^2); %gradient magnitude
        
    I_angle=zeros(nr,nc);
    for j=1:nr
        for i=1:nc
            if abs(Ix(j, i))<=0.0001 & abs(Iy(j, i))<=0.0001
                I_angle(j, i)=0.00;
            else
                if Ix(j, i)~=0
                    Ipr(j, i) = atan(Iy(j, i)/Ix(j, i));
                    I_angle(j, i) = Ipr(j,i) * 180/pi;
                    if I_angle(j, i) < 0
                        I_angle(j, i) = 180 + I_angle(j, i);
                    end
                else
                    Ipr(j, i)=pi/2;
                    I_angle(j, i)=90;
                end
            end
        end
    end
        
    nr_size = nr/nr_b;
    nc_size = nc/nc_b;
        
    Image_HoG = zeros(1, nbin*nr_b*nc_b);
    for i=1:nr_b
        for j=1:nc_b
            I_mag_block = I_mag((i-1)*nr_size+1:i*nr_size, (j-1)*nc_size+1:j*nc_size);
            warning off % Hide the warning messages
            I_angle_block = I_angle((i-1)*nr_size+1:i*nr_size, (j-1)*nc_size+1:j*nc_size);
            gh=HoG1(I_mag_block, I_angle_block,nbin);
            ngh=Histogram_Normalization(gh);
            pos=(j-1)*nbin+(i-1)*nc_b*nbin+1;
            Image_HoG(pos:pos+nbin-1) = ngh;
        end
    end
end