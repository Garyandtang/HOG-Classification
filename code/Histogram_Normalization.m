function [nhist] = Histogram_Normalization(ihist)
    %Normalize input histogram ihist to a unit histogram
    total_sum = sum(ihist);
    nhist = ihist/total_sum;
end