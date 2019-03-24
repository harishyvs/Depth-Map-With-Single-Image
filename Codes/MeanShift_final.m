function [final,no_clusterPoints] = MeanShift_final(I,Threshold)
% I=imread(I);
I = im2double(I);
input = reshape(I,size(I,1)*size(I,2),3);                                       

[individualPoint_clusterMap,clustCent,cluster_individualPoint] = MeanShift(input',Threshold);    
for i = 1:length(cluster_individualPoint)                                             
    input(cluster_individualPoint{i},:) = repmat(clustCent(:,i)',size(cluster_individualPoint{i},2),1); 
end

final = reshape(input,size(I,1),size(I,2),3);                                   
no_clusterPoints = length(cluster_individualPoint);
% imshow(final);
end