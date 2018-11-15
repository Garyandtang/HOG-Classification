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