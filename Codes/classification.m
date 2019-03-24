function type = classification(labelledImage)
    [numRows,numCols,~] = size(labelledImage);
    values= 1:10:numCols;
    jumps = 0;
    skyCount=0;
    currentLabel = 0;
    currentJumpCount = 0;
	valuesSize = size(values,2);
    for j = 1:valuesSize
        flag=0;
        for i = 1:numRows
            if(i==1)
                if(labelledImage(i,values(1,j)) == 1)
                    currentLabel = 1;
                    currentJumpCount = 1;
					skyCount=skyCount+1;
                    continue;
                else
                    flag=1;
                    break;
                end
            elseif(i~=numRows)
                if(labelledImage(i,values(1,j))~=currentLabel)
                    currentJumpCount = currentJumpCount+1;
                    currentLabel = labelledImage(i,values(1,j));
                end
            end
        end
        if(flag==0)
            if(currentJumpCount<=5)
                jumps=jumps+1;
            end
        end
    end
    if(jumps >= 0.65*valuesSize)
        type = 0;
    elseif(skyCount >= 0.35*valuesSize)
        type = 1;
    else
        type = 2;
    end
end