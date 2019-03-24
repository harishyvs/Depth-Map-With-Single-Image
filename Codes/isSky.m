function result = isSky(i, r, g, b)
   if(i > 0.65 && b >= 160  && g >=70 && b+15>=g && b+15>=r)
       result = 1;
   else
      result = 0;
   end
end