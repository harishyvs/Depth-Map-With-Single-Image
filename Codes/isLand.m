function result = isLand(i, r, g, b)
   if(i>0.5 && (r>100 && r<=200) && (g>100 && g<=190) && (b>135 && b<=180))
       result = 1;
    elseif(i>0.4 && b<=100 && r<=200 && g>=b && g>=r)
        result = 1;
   else
      result = 0;
   end
end
