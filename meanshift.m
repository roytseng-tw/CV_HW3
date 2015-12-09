function [y] = meanshift(x,hr,isLuv,th)
% for RGB space, x should ranges from 0~255.
%% Argument Check
if nargin < 3
    error('please type help for function syntax(not support now)');
elseif nargin == 3
    if sum(ismember(isLuv,[0,1])) == 0
        error('isLuv option has to be 0 or 1');
    end
    th = 3/100;
elseif nargin == 4
    if th<0 || th >1
        error('threshold should be in [0,1]');
    end
elseif nargin > 4
    error('too many input arguments')
end

%% initialization
[height,width,depth] = size(x);
x = double(reshape(x,height*width,depth));
if isLuv
    normFactor = max(mean(abs(x),2));
else
    normFactor = 255;
end
y = x;

%%
totalMask = false(height*width, 1);
for i = 1:height*width
    if(totalMask(i))
        continue;
    end
    done = 0;
    accum = 0;
    accMask = false(height*width, 1);
    cnt = 0;
    diffVec = bsxfun(@minus,y,x(i,:));
    idList = (1:height*width)';
    while ~done
        MS = y(i,:) - x(i,:);
        if any(MS)
            diffVec = bsxfun(@plus,MS,diffVec);
            x = y;
        end
        diffSqr = sum(diffVec.^2, 2);
        mask = diffSqr < hr^2;
        idInRange = idList(mask);
        accMask(idInRange) = true;        
        cnt = cnt + sum(mask,1);
        accum = accum + sum(x(idInRange,:),1);
        MS =  accum/cnt - x(i,:);
        idList = idList(~mask);
        diffVec = diffVec(~mask,:);
        if isLuv
            normMS = mean(abs(MS))/normFactor;
        else
            normMS = mean(MS)/normFactor;
        end
        if normMS < th
            done = 1;
            y(accMask,:) = repmat(accum/cnt, cnt, 1);
            totalMask = totalMask | accMask;
        else
            y = y + accMask*MS;
        end
    end
    fprintf('%d\n',i);
    x = y;
end
if isLuv
    y = reshape(y,height,width,depth);
else
    y = reshape(uint8(y),height,width,depth);
end
