%%
vr = VideoReader('data/jaguar.avi');
info = mmfileinfo('data/jaguar.avi');
m = info.Video.Height;
n = info.Video.Width;

bg = im2double(imresize(imread('data/grass.jpg'),[m n]));

vw = VideoWriter('data/jaguar_on_grass.avi');
open(vw);

isFirstFrame = true;
while hasFrame(vr)
    frame = im2double(readFrame(vr));
    X = reshape(frame,m*n,3);
    if isFirstFrame
        isFirstFrame = false;
        [~,c] = mykmeans(X,2);
    end
    [~,labels] = min(bsxfun(@plus,-2*X*c',dot(c,c,2)'),[],2);
    bgIdx = labels(1);
    mask = reshape(labels~=bgIdx,m,n);
    mask = imerode(mask,strel('square',3));
    H = fspecial('gaussian',5,1.2);
    mask = imfilter(double(mask),H,0);
    mask = repmat(mask,1,1,3);
    mask = mask / max(mask(:));
    newframe = frame.*mask + bg.*(1-mask); 
    %imshow(frame); break;
    writeVideo(vw,newframe);
end
close(vw);
