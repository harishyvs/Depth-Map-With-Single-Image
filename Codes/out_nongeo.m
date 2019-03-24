function [required_im,y_vanishingPoint]= out_nongeo(im_type,temp_fin,im_name)
    [rows,cols]=size(temp_fin);
    y_vanishingPoint=0;
    if im_type == 0
        y=zeros(rows,1);
        for i=1:cols
           temp=find(temp_fin(:,i)==200|temp_fin(:,i)==255);
           if( length(temp) == 0)
            y(i)=rows-1;
           else
               y(i)=temp(1);
           end
        end
        y_vanishingPoint=max(y);
        x_vanishingPoint=round(cols/2);
        y_vanishingPoint=round(y_vanishingPoint);
        required_im=zeros(rows,cols);
        I=1;
        offset=(1-200/255)/(rows-y_vanishingPoint);
        i=rows;
        while i>y_vanishingPoint && i>1
            required_im(i,:)=I;
            I=I-offset;
            i=i-1;
        end
        required_im(1:y_vanishingPoint,:) = 60/255;
    else
        required_im=out_in(im_type,im_name);
    end
end
