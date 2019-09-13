%*********************************************************************
%  Size-area analysis of graphene/graphite particles
%  Last modified: 08/25/2017
%*********************************************************************

clear all;
clc;
tic;

% LOAD THE IMAGE
%*************************************************************************

name = input('Enter the file name without the file extension...','s');
name = [name '.tif'];
RR = imread(name);

imgmodel = imagemodel(image(RR));

str = getImageType(imgmodel);

TF = strcmp(str, 'truecolor');
if TF==1
    RR=rgb2gray(RR);
end
close;
RR = double(RR);
RR = RR/256.0;

[M,N]=size(RR);
center_row=floor(M/2+1);
center_col=floor(N/2+1);

%****************************************************



% FINDING THE SCALE
%***********************************************

scalebar = input('\n Enter the scalebar distance in micrometers...');
kk=1;

figure (1)
imagesc(RR);

text(50,50,'Select the end points of the scale bar','FontSize',16,'color','y');

points = ginput(2);

xx = points(:,1);
yy = points(:,2);

r=sqrt((xx(1,1)-xx(2,1))^2);%+((yy(1,1)-yy(2,1))^2));
scale= scalebar/r;
close;


%*******************************************************
%  CROPPING THE IMAGE BY SELECTING REGION OF INTEREST
%*******************************************************

figure();
imshow(RR);
raw=[];


text(50,50,'Click top-left and then bottom-right co-ordinate of the lighter domain for your region of interest','FontSize',16,'color','y');

CROP = ginput(2);           % top-left and bottom-right co-ordinates
close;

row_1     = round(CROP(1,2));
row_n     = round(CROP(2,2));
col_1     = round(CROP(1,1));
col_n     = round(CROP(2,1));

kk=1;
tt=1;
for i=row_1:row_n
    for j=col_1:col_n
        raw(kk,tt)=RR(i,j);
        tt=tt+1;
    end
    tt=1;
    kk=kk+1;
end



I = medfilt2(raw);
%I = raw;

BW = imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',0.3);
BW2 = imcomplement(BW);

[mmm, nnn] = size(BW2);

%************************************************************************
% Removing unwanted parts
%************************************************************************




figure();
imshow(BW2);
text(50,40,'Freehand drawing to remove unwanted parts. Left click to continue, keyboard press to stop','FontSize',12,'color','y');

n=0;


while n==0
    bin0=[];
   
h0=imfreehand();
bin0=h0.createMask();

BW2=BW2-bin0;
n = waitforbuttonpress ;
end

for col=1:nnn
    for row=1:mmm
        if BW2(row,col)<0
            BW2(row,col)=0;
        end
    end
end

close;





L = bwlabel(BW2);

cc = bwconncomp(BW2);

NL = cc.NumObjects;

k=1;

for i=1:NL
Obj = (L==i);
Area(k) = regionprops(Obj,'Area') ;
k=k+1;
end


QB = struct2array(Area);
Area_um  = QB.*(scale*scale);

%write to a text file
fid = fopen(strcat('../../../Users/krist/Projects/area.csv'),'a');
for i=1:max(size(Area_um))
    fprintf(fid,'%f\n', Area_um(i));
end


imshowpair(I,BW2,'montage')





toc




