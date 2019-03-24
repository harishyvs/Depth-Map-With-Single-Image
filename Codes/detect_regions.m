function [regionImage, labeledImage] = detect_regions(hsvImage, medImage)
    [numRows,numCols,~] = size(hsvImage);
    regionImage =  uint8(zeros(numRows,numCols));
    labeledImage =  zeros(numRows,numCols);
    for i = 1:numRows
        for j = 1:numCols
            intensity = hsvImage(i,j,3);
            red = medImage(i,j,1);
            blue = medImage(i,j,2);
            green = medImage(i,j,3);
            if(isSky(intensity,red,blue,green))
                regionImage(i,j) = 0;
                labeledImage(i,j) = 1;
            elseif(isFarMountain(intensity, red,blue,green))
                regionImage(i,j) = 60;
                labeledImage(i,j) = 2;
            elseif(isNearMountain(intensity, red, blue, green))
                regionImage(i,j) = 120;
                labeledImage(i,j) = 2;
            elseif(isLand(intensity, red, blue, green))
                regionImage(i,j) = 200;
                labeledImage(i,j) = 3;
            else
                regionImage(i,j) = 255;
                labeledImage(i,j) = 4;
            end
        end
    end
end