function [individualPoint_clusterMap,Clust_center,cluster_individualPoint]=MeanShift(data_Pts,Threshold)

%data_Pts is a 3 x Pixel area vector
%Pixel_area is the total rows and columns in one dimension
%dim is the number of channels

[dim,Pixel_area]=size(data_Pts);
%variable to initialize the count of total cluster points
num_Cp=0;

%Variable to track which cluster the pixel belongs
% track=zeros(Pixel_area,1);

%Store the converged RGB value for each cluster point
Clust_center=[];
old_mean=0;

%variable to keep track what all points belong to a particular cluster
Clust_votes=zeros(1,Pixel_area);


%variable to keep track which points have already been clustered in 
%various initializations
already_visited=zeros(1,Pixel_area);
Pixel_area1=1:Pixel_area;
num_iter=Pixel_area;
while num_iter
    
    %Selcting random pixel to initialize it as the cluster center 
    random_pixels=ceil(num_iter*rand);
    value_=Pixel_area1(random_pixels);
    %Pixel value in the starting seeding point
    mean_value=data_Pts(:,value_);
    %array to keep the votes to a particular pixel 
    counter=zeros(1,Pixel_area);
    myMembers=[];
    %empty array to keep adding the elements which are inside the threshold
%     inliners=zeros(1,num_iter);
  while 1
%     for i=1:num_iter
%         %Calculate the distance between all the pixel points 
%         dist=data_Pts(:,random_pixels)-data_Pts(:,i);
%         if dist<Threshold
%             inliners=[inliners i];
%             counter(i)=counter(i)+1;
% %             track(i)=track;
%         end
%     end
    dist=sum((repmat(mean_value,1,Pixel_area)-data_Pts).^2);
    inliners=find(dist<Threshold^2);
    counter(inliners)=counter(inliners)+1;
    
    oldMean=mean_value;
    mean_value=mean(data_Pts(:,inliners),2);
    myMembers=[myMembers inliners];
    already_visited(myMembers)=1;
    %This part of the if loop checks that after convergence if the new
    %formed cluster center is similar to older ones and if not it adds a new
    %cluter center
    if norm(oldMean-mean_value) < 1e-3*Threshold
        %variable to ckeck 
        mrge=0;
%         if num_Cp~=0
          for j=1:num_Cp
                %distance between various cluster
                diff_cluster=norm(mean_value-Clust_center(:,j));
                %check if the new cluster added is already in the bound of any
                %older ones
                if diff_cluster<Threshold/2
                    mrge=j;
                    break;
                end
           end
%         end
        if mrge>0
            Clust_center(:,mrge)=0.5*(mean_value+Clust_center(:,mrge));
            Clust_votes(mrge,:)=Clust_votes(mrge,:)+counter;
        else
            num_Cp=num_Cp+1;
            Clust_center(:,num_Cp)=mean_value;
            Clust_votes(num_Cp,:)=counter;
        end
%         if num_Cp==0 
%             num_Cp=num_Cp+1;
%             Clust_center(:,num_Cp)=mean_value;
%             Clust_votes(num_Cp,:)=counter;
%         end
        break;

    end
    
  end    

 Pixel_area1=find(already_visited==0);
 num_iter=length(Pixel_area1);
  
end
[val,individualPoint_clusterMap]=max(Clust_votes,[],1);
cluster_individualPoint=cell(num_Cp,1);
for i1=1:num_Cp
    cell_members=find(i1==individualPoint_clusterMap);
    cluster_individualPoint{i1}=cell_members;

end
  

  
  
