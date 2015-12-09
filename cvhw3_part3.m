%% read data
I = imread('data/AhriPoro.jpg');
[m,n,d] = size(I);
I2 = colorspace('RGB->Luv',I);

%% mean-shift on color
isLuv = true;
hr = 16; %color bandwidth
%------------------------------
% hr: RGB = (16,32), Luv = (7,14)
%------------------------------
if isLuv
    y = meanshift(I2,hr,isLuv);
    y = colorspace('RGB<-Luv',y);
else
    y = meanshift(I,hr,isLuv);
end
figure();
imshow(y);

%% mean-shift on color + space
isLuv = true;
hs = 10; %spatial bandwidth
hr = 16; %color bandwidth
%---------------------------------
% hs: (10,20)
% hr: RGB = (16,32), Luv = (7,14)
%---------------------------------
if isLuv
    y = meanShiftPixCluster(I2,hs,hr,isLuv);
    y = colorspace('RGB<-Luv',y);
else
    y = meanShiftPixCluster(I,hs,hr,isLuv);
end
figure();
imshow(y);

%% save image
imwrite(y, 'meanshift_luv_hs20_hr14.png');
