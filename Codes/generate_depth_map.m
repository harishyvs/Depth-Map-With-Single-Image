function [final,regionImage] = generate_depth_map(image)
    %image='./Input_images/image.png';
    
%     image
    I=imread(char(image));
    
    [final,no_clusterPoints]=MeanShift_final(I,.2);
    figure;
    imshow(final);
    H=rgb2hsv(final);
    final=final.*255;
    final2 = final; % applying median filter on segmented image
    final2(:,:,1)= medfilt2(final(:,:,1),[5 5]);
    final2(:,:,2)= medfilt2(final(:,:,2),[5 5]);
    final2(:,:,3)= medfilt2(final(:,:,3),[5 5]);
    med = final2;
%     final2 = uint8(final2);
    final = uint8(final);

    [regionImage, labeledImage] = detect_regions(H,med);
    type = classification(labeledImage)
%     final1=uint8(regionImage);
%     figure;
%     imshow(final1)
end
