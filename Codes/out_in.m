function [req_img]=out_in(imageType,fileName)
Img =imread(fileName);

I=rgb2gray(Img);

Ie=edge(I,'sobel');

[H,teta,perpDistance] = hough(Ie);    
cielH = ceil(0.2*max(H(:)));    
P = houghpeaks(H,20,'threshold',cielH);
x = teta(P(:,2));
y = perpDistance(P(:,1));

lines = houghlines(I,teta,perpDistance,P);
[rows, columns] = size(Ie);
n=length(lines);
zc = (n*(n-1))/2;
acc=zeros(zc,2);
k=1;
for i=1:n
    pointX = [lines(i).point1; lines(i).point2];
    for j=i+1:n
       pointY = [lines(j).point1; lines(j).point2];
       slopeFunc = @(line) (line(2,2) - line(1,2))/(line(2,1) - line(1,1));
       mx = slopeFunc(pointX);
       my = slopeFunc(pointY);
       interceptFunc = @(line,m) line(1,2) - m*line(1,1);
       cx = interceptFunc(pointX,mx);
       cy = interceptFunc(pointY,my);
       if mx~=my
           acc(k,1)=(cy-cx)/(mx-my);
           acc(k,2)=mx*(cy-cx)/(mx-my) + cx;
           k=k+1;
       end
     end
end


fsa = floor(zc/2);
clusters=clusterdata(acc,fsa);
c=find(clusters==mode(clusters));
Xvp=mean(acc(c,1));
Yvp=mean(acc(c,2));

xLeftCount=1;
xRightCount=1;
yLeftCount=1;
yRightCount=1;
dict=struct;

for k = 1:length(lines)
   point = [lines(k).point1; lines(k).point2];
   x1 = point(1,1);
   y1 = point(1,2);
   x2 = point(2,1);
   y2 = point(2,2);

   slope = (y2-y1)/(x2-x1);
   xLeft = 1;
   yLeft = slope * (xLeft - x1) + y1;
   xShift = Xvp-x1;
   yShift = Yvp-y1;
   P=(slope*xShift-yShift)/sqrt(slope^2+1);
   if(abs(P)>6)
    continue;
   end

   if(x1 == x2)
    continue;
   end

   if 0<yLeft && yLeft<=rows
    dict.yLeft(yLeftCount)=yLeft;
    yLeftCount=yLeftCount+1;
   end

   xRight = columns;
   yRight = slope * (xRight - x1) + y1;

   if 0<yRight && yRight<=rows
    dict.yRight(yRightCount)=yRight;
    yRightCount=yRightCount+1;
   end

   slope = (x2-x1)/(y2-y1);
   yLeft = 1;
   xLeft = slope * (yLeft - y1) + x1;
   if 0<xLeft && xLeft<=columns
    dict.xLeft(xLeftCount)=xLeft;
    xLeftCount=xLeftCount+1;
   end
   yRight = rows;
   xRight = slope * (yRight - y1) + x1;

   if 0<xRight && xRight<=columns
    dict.xRight(xRightCount)=xRight;
    xRightCount=xRightCount+1;
   end
end

if(~isfield(dict, 'xLeft'))
    dict.xLeft(1)=1;
    dict.xLeft(2)=columns;
end

if(~isfield(dict, 'xRight'))
    dict.xRight(1)=1;
    dict.xRight(2)=columns;
end

if(~isfield(dict, 'yLeft'))
    dict.yLeft(1)=1;
    dict.yLeft(2)=rows;
end

if(~isfield(dict, 'yRight'))
    dict.yRight(1)=1;
    dict.yright(2)=rows;
end


Xvp=round(Xvp);
Yvp=round(Yvp);
req_img=zeros(rows,columns);
gradC = 1-60/255;
if(Xvp<columns/2)
    i=columns;
    currIntensity=1;
    gradient=gradC/(columns-Xvp);
    while i>1 && i>Xvp
        req_img(:,i)=currIntensity;
        currIntensity=currIntensity-gradient;
        i=i-1;
    end
    req_img(:,1:Xvp)=currIntensity;
end

if(Xvp>=columns/2)
    i=1;
    currIntensity=1;
    gradient=gradC/(Xvp);
    while i<=columns && i<Xvp 
        req_img(:,i)=currIntensity;
        currIntensity=currIntensity-gradient;
        i=i+1;
    end
    req_img(:,Xvp:end)=currIntensity;
end

H=rows;W=columns;
hbw = (H-1)/(W-1);
if (Xvp>=W-1 && -hbw*Xvp+H-1<Yvp< hbw* Xvp )
    x1=1;
    y1=max(dict.yLeft);
    [cx,cy,~]=improfile(~Ie,[x1 Xvp],[y1 Yvp]);
    cx=round(cx);
    cy=round(cy);
    currIntensity=1;
    gradient=gradC/(size(cx,1)+rows-y1);
    i=rows;
    while i>y1
        req_img(i,:)=currIntensity;
        currIntensity=currIntensity-gradient;
        i=i-1;
    end
    for i=1:size(cx,1)
        if cx(i)>=columns
            break;
        end
        req_img(1:cy(i),cx(i))=currIntensity;
        req_img(cy(i),cx(i):end)=currIntensity;
        currIntensity=currIntensity-gradient;
    end
end

if (Xvp<=0 && hbw*Xvp<Yvp<-hbw*Xvp+H-1)
    x1=columns;
    y1=max(dict.yRight);
    [cx,cy,~]=improfile(~Ie,[x1 Xvp],[y1 Yvp]);
    cx=round(cx);
    cy=round(cy);
    gradient=gradC/(size(cx,1)+rows-y1);
    i=rows;
    currIntensity=1;
    while i>y1
        req_img(i,:)=currIntensity;
        currIntensity=currIntensity-gradient;
        i=i-1;
    end
    for i=1:size(cx,1)
        if cx(i)<=1
            break;
        end
        req_img(1:cy(i),cx(i))=currIntensity;
        req_img(cy(i),1:cx(i))=currIntensity;
        currIntensity=currIntensity-gradient;
    end
end

if 0<Xvp && Xvp<W-1 && 0<Yvp && Yvp<H-1 && Xvp<=columns/2 && imageType==2
    currIntensity=0;
    gradient=1/(rows-Yvp);
    x1=1;y1=max(dict.yLeft);
    slope1=(x1-Xvp)/(y1-Yvp);
    x2=max(dict.xRight);y2=rows;
    slope2=(x2-Xvp)/(y2-Yvp);
    for y=Yvp:rows
        xL1 = round(slope1 * (y - y1) + x1);
        if xL1<1
            xL1=1;
        end
        xL2 = round(slope2 * (y - y2) + x2);
        if xL2>=columns
            xL2=columns;
        end
        req_img(y,xL1:xL2)=currIntensity;
        currIntensity=currIntensity+gradient;
    end

    x1=max(dict.xRight);y1=rows;
    slope2=(y2-Yvp)/(x2-Xvp);
    x2=max(dict.xLeft);y2=1;
    slope1=(y1-Yvp)/(x1-Xvp);
    currIntensity=0;
    gradient=1/(columns-Xvp);
    for x=Xvp:columns
        yL1 = round(slope1 * (x - x1) + y1);
        yL2 = round(slope2 * (x - x2) + y2);
        if yL1>rows
            yL1=rows;
        end
        if yL2<1
            yL2=1;
        end
        req_img(yL2:yL1,x)=currIntensity;
        currIntensity=currIntensity+gradient;
    end

    x1=1;y1=min(dict.yLeft);
    slope1=(x1-Xvp)/(y1-Yvp);
    x2=max(dict.xLeft);y2=1;
    slope2=(x2-Xvp)/(y2-Yvp);
    currIntensity=0;
    gradient=1/(Yvp);
    y=Yvp;
    while y>=1
        xL1 = round(slope1 * (y - y1) + x1);
        if xL1<1
            xL1=1;
        end
        xL2 = round(slope2 * (y - y2) + x2);
        if yL2>columns
            yL2=columns;
        end
        req_img(y,xL1:xL2)=currIntensity;
        currIntensity=currIntensity+gradient;
        y=y-1;
    end

    x1=1;y1=min(dict.yLeft);
    slope1=(y1-Yvp)/(x1-Xvp);
    x2=1;y2=max(dict.yLeft);
    slope2=(y2-Yvp)/(x2-Xvp);
    currIntensity=0;
    gradient=1/(Xvp);
    x=Xvp;
    while x>=1
        yL1 = slope1 * (x - x1) + y1;
        yL1 = round(yL1);
        yL2 = slope2 * (x - x2) + y2;
        yL2 = round(yL2);
        if yL2>rows
            yL2=rows;
        end
        if yL1<1
            yL1=1;
        end
        req_img(yL1:yL2,x)=currIntensity;
        currIntensity=currIntensity+gradient;
        x=x-1;
    end
end
if 0<Xvp && Xvp<W-1 && 0<Yvp && Yvp<H-1 && Xvp>columns/2 && imageType==2
    currIntensity=0;
    gradient=1/(rows-Yvp);
    x1=min(dict.xRight);
    y1=rows;
    slope1=(x1-Xvp)/(y1-Yvp);
    x2=columns;
    y2=max(dict.yRight);
    slope2=(x2-Xvp)/(y2-Yvp);
    for y=Yvp:rows
        xL1 = slope1 * (y - y1) + x1;
        xL1 = round(xL1);
        xL2 = slope2 * (y - y2) + x2;
        xL2 = round(xL2);
        if xL1<1
            xL1=1;
        end
        if xL2>=columns
            xL2=columns;
        end
        req_img(y,xL1:xL2)=currIntensity;
        currIntensity=currIntensity+gradient;
    end
    x1=columns;y1=max(dict.yRight);
    slope1=(y1-Yvp)/(x1-Xvp);
    x2=columns;y2=min(dict.yRight);
    slope2=(y2-Yvp)/(x2-Xvp);
    currIntensity=0;
    gradient=1/(columns-Xvp);
    for x=Xvp:columns
        yL1 = slope1 * (x - x1) + y1;
        yL1 = round(yL1);
        yL2 = slope2 * (x - x2) + y2;
        yL2 = round(yL2);
        if yL1<1
            yL1=1;
        end
        if yL2>rows
            yL2=rows;
        end
        req_img(yL2:yL1,x)=currIntensity;
        currIntensity=currIntensity+gradient;
    end

    x1=columns;y1=min(dict.yRight);
    slope1=(x1-Xvp)/(y1-Yvp);
    x2=min(dict.xLeft);y2=1;
    slope2=(x2-Xvp)/(y2-Yvp);
    y=Yvp;
    gradient=1/(columns-Xvp);
    currIntensity=0;
    while y>=1
        xL1 = slope1 * (y - y1) + x1;
        xL2 = slope2 * (y - y2) + x2;
        xL1 = round(xL1);
        xL2 = round(xL2);
        if xL2<1
            xL2=1;
        end
        if xL1>columns
            xL1=columns;
        end
        req_img(y,xL2:xL1)=currIntensity;
        currIntensity=currIntensity+gradient;
        y=y-1;
    end


    x1=min(dict.xLeft);y1=1;
    slope1=(y1-Yvp)/(x1-Xvp);
    x2=min(dict.xRight);y2=rows;
    slope2=(y2-Yvp)/(x2-Xvp);
    currIntensity=0;
    x=Xvp;
    gradient=1/(columns-Xvp);
    
    while x>=1
        yL1 = slope1 * (x - x1) + y1;
        yL2 = slope2 * (x - x2) + y2;
        yL1 = round(yL1);
        yL2 = round(yL2);
        if yL2>rows
            yL2=rows;
        end
        if yL1<1
            yL1=1;
        end
        req_img(yL1:yL2,x)=currIntensity;
        x=x-1;
        currIntensity=currIntensity+gradient;
    end
end
end
