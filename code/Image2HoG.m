function [Image_HoG] = Image2HoG(I,nr_b,nc_b,nbin)
    %use sobel operator to calculate the gradient of the image
    Sx=[-1 0 1; -2 0 2; -1 0 1];
    Sy=[-1 -2 -1; 0 0 0; 1 2 1];
    [nr nc]=size(I);
   
    Ix=imfilter(double(I), Sx);
    Iy=imfilter(double(I), Sy);
    %Calcuate gradient magnitude
    I_mag=sqrt(Ix.^2+Iy.^2); 
    
    %Calcuate gradient magnitude    
    I_angle=zeros(nr,nc);
    for j=1:nr
        for i=1:nc
            if (abs(Ix(j, i))<=0.0001 & abs(Iy(j, i))<=0.0001)
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
    %Calculate the HOG feature 
    %The dimension of HOG feature is equal to nr*nc*nbin
    Image_HoG = zeros(1, nbin*nr_b*nc_b);
    for i=1:nr_b
        for j=1:nc_b
            warning off;
            I_mag_block = I_mag((i-1)*nr_size+1:i*nr_size, (j-1)*nc_size+1:j*nc_size);
            I_angle_block = I_angle((i-1)*nr_size+1:i*nr_size, (j-1)*nc_size+1:j*nc_size);
            gh=HoG1(I_mag_block, I_angle_block,nbin);
            ngh=Histogram_Normalization(gh);
            pos=(j-1)*nbin+(i-1)*nc_b*nbin+1;
            Image_HoG(pos:pos+nbin-1) = ngh;
        end
    end
end