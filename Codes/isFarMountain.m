function result = isFarMountain(i, r, g, b)
    %result =1;
    
   % return;
   if(i > 0.1 && (b>=20 && b<=160) && (g>=15 && g<=255) && (b>=g && b>=r))
       result = 1;
   elseif(i>0.4 && i<0.8 && (r>=80 && r<=160) && (g>=80 && g<=160) && (b>=80 && b<=160))
       result = 1;
   else
      result = 0;
   end
end