function result = isNearMountain(i, r, g, b)
   if(i>0.45 && b<=100 && g<=255 && r>=100 && (r>=b && r>=g))
       result = 1;
   elseif( (i>0.14 && i<0.65) && b <= 120 && g<=120 && r<=120  && (g+10>=b && g+10>=r))
       result = 1;
   else
      result = 0;
   end
end