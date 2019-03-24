function final_output = DepthMap(filename)
    %filename = 'samples/image1.jpg');
    im = imread(filename);

    % computing mean shift clustering
    [output,~] = Ms(im,0.1);

     % finding hsv image 
    output3 = rgb2hsv(output);
    output=output.*255;
    output2 = output;
    
    % applying median filter on segmented image
    output2(:,:,1)= medfilt2(output(:,:,1),[5 5]);
    output2(:,:,2)= medfilt2(output(:,:,2),[5 5]);
    output2(:,:,3)= medfilt2(output(:,:,3),[5 5]);
    med = output2;
    img_hsv = (output3);
    [x,y,~] = size(output3);

    % region detection by color based rules
    % 1-- sky ; 2 -- far mountain ; 3 -- near mountain ; 4 -- land ;
    % 5 -- other
    
    fin_out = zeros(x,y);
    temp = zeros(x,y);
    for i = 1:x
        for j = 1:y
            if(img_hsv(i,j,3)>0.65 && (med(i,j,3)>=160 && med(i,j,3)<=255) && (med(i,j,2)>=70 && med(i,j,2)<=255) && (med(i,j,1)>=0) && (med(i,j,3)+15>=med(i,j,2) && med(i,j,3)+15>=med(i,j,1)))
                temp(i,j) = 1;
                fin_out(i,j) = 0;
            elseif(img_hsv(i,j,3)>0.1 && (med(i,j,3)>=20 && med(i,j,3)<=160) && (med(i,j,2)>=15 && med(i,j,2)<=255) && (med(i,j,1)>=0) && (med(i,j,3)>=med(i,j,2) && med(i,j,3)>=med(i,j,1)))
                temp(i,j) = 2;
                fin_out(i,j) = 60;
            elseif(img_hsv(i,j,3)>0.45 && ( med(i,j,3)<=100) && ( med(i,j,2)<=255) && (med(i,j,1)>=100) &&(med(i,j,1)>=med(i,j,3) && med(i,j,1)>=med(i,j,2)))
                temp(i,j) = 3;
                fin_out(i,j) = 120;
            elseif(img_hsv(i,j,3)>0.14 && img_hsv(i,j,3)<0.65 && (med(i,j,3)<=120) && ( med(i,j,2)<=120) && (med(i,j,1)<=120) &&(med(i,j,2)+10>=med(i,j,3) && med(i,j,2)+10>=med(i,j,1)))
                temp(i,j) = 3;
                fin_out(i,j) = 120;
            elseif(img_hsv(i,j,3)>0.4 && ( med(i,j,3)<=100) && ( med(i,j,2)<=255) && (med(i,j,1)<=200) &&(med(i,j,2)>=med(i,j,3) && med(i,j,2)>=med(i,j,1)))
                temp(i,j) = 4;
                fin_out(i,j) = 200;
            elseif(img_hsv(i,j,3)>0.4 && img_hsv(i,j,3)<0.8 && (med(i,j,1)>=80 && med(i,j,1)<=160) && (med(i,j,2)>=80 && med(i,j,2)<=160) && (med(i,j,3)>=80 && med(i,j,3)<=160))
                temp(i,j) = 2;
                fin_out(i,j) = 60;
            elseif(img_hsv(i,j,3)>0.6 && (med(i,j,1)>165 && med(i,j,1)<=200) && (med(i,j,2)>140 && med(i,j,2)<=190) && (med(i,j,3)>135 && med(i,j,3)<=180))
                temp(i,j) = 4;
                fin_out(i,j) = 200;
            else
                temp(i,j) = 5;
                fin_out(i,j) = 255;
            end
        end
    end


    % applying median filter to remove outliers.
    temp_fin = fin_out;
    temp_fin = medfilt2(fin_out,[5 5]);

    temp_label = zeros(x,y);


    for i = 1:x
        for j =1:y
            if(temp_fin(i,j) ==0)
                temp_label(i,j) = 1;
            elseif((temp_fin(i,j)==60) || (temp_fin(i,j)==120))
                temp_label(i,j)=2;
            elseif(temp_fin(i,j)==200)
                temp_label(i,j)=3;
            elseif(temp_fin(i,j)==255)
                temp_label(i,j)=4;
            end
        end
    end

    % image classification into outdoor or indoor types.
    vals= 1:10:y;
    count = 0;
    count2=0;
    temp_col = 0;
    temp_cnt = 0;
    for j = 1:size(vals,2)
        flag=0;
        for i = 1:x
            if(i==1)
                if(temp_label(i,vals(1,j)) == 1)
                    temp_col = 1;
                    temp_cnt = 1;
                    continue;
                else
                    flag=1;
                    break;
                end
            elseif(i<x)
                if(temp_label(i,vals(1,j))==temp_col)
                    continue;
                elseif(temp_label(i,vals(1,j))>temp_col)
                    temp_cnt = temp_cnt+1;
                    temp_col = temp_label(i,vals(1,j));
                elseif(temp_label(i,vals(1,j))<temp_col)
                    temp_col = temp_label(i,vals(1,j));
                    temp_cnt = temp_cnt+1;
                end
            end
        end
        if(flag==0)
            count2=count2+1;
            if(temp_cnt<=5)
                count=count+1;
            end
        end
    end
    % 0 -- outdoor without geometric elements , 1-- outdoor with geometric elements 2-- indoor

    if(count >= 0.65*size(vals,2))
        type=0;
    elseif(count2>=0.35*size(vals,2))
        type=1;
    else
        type = 2;
    end
    q_depthmap = temp_fin;

    disp(type);
    [g_depthmap,Yvp] = VO(type,q_depthmap,filename);
    if(type==1)
        g_temp = g_depthmap.*255;
        final_output = g_temp;
        final_output(q_depthmap==0) = 0;
    elseif(type==0)
        final_output = g_depthmap;
        final_output(1:Yvp,:)=q_depthmap(1:Yvp,:)./255;
        final_output = final_output.*255; 
    else
        final_output = g_depthmap.*255;
    end
    % plotting 
    figure;
    subplot(1,3,1);
    imshow(uint8(fin_out));
    title('Qualitative depth map');
    subplot(1,3,2);
    imshow(med./255);
    title('segmented image');
    subplot(1,3,3);
    imshow(img_hsv);
    title('hsv image');

%     figure;
%     subplot(1,2,1);
%     imshow(im);
%     title('Actual image');
%     subplot(1,2,2);
%     imshow(uint8(q_depthmap));
%     title('Qualitative depth map');
    
    figure;
    subplot(2,2,1);
    imshow(im);
    title('Actual Image');
    subplot(2,2,2);
    imshow(uint8(q_depthmap));
    title('Qualitative Depthmap');
    subplot(2,2,3);
    imshow(g_depthmap);
    title('Geometric Depthmap');
    subplot(2,2,4);
    imshow(uint8(final_output));
    title('Final Depthmap');
    
end