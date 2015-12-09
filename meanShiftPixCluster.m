function [y, MS] = meanShiftPixCluster(x,hs,hr,isLuv,th)
% FUNCTION: meanShiftPixCluster implements the classic mean shift pixel
% clustering algorithm introduced in Cmaniciu etal.'s PAMI paper 
% "Mean shift: a robust apporach toward feature space analysis", 2002.
% -------------------------------------------------------------------------
% Input: 
%       x = an input image (either gray or rgb, please expect long time processing if image size is large)
%      hs = the bandwidth of spatial kernel (see Eq.(35) in the cited paper)
%      hr = the bandwidth of feature kernel (see Eq.(35) in the cited paper)
%      th = the threshod of the convergence criterion (default = .25)
%  plotOn = switch on/off the image display of intermediate results (default = 1)
%
% Output:
%       y = the output pixel clustered image
%      MS = the output of averaged mean shift
% -------------------------------------------------------------------------
%% Argument Check
if nargin<4
    error('please type help for function syntax')
elseif nargin == 4
    th = 10/100;
elseif nargin == 5
    if th < 0 || th > 1
        error('threshold should be in [0,1]')
    end
elseif nargin > 5
    error('too many input arguments')
end
%% initialization
x = double(x);
[height,width,depth] = size(x);
if isLuv
    normFactor = max(max(mean(abs(x),3)));
else
    normFactor = 255;
end
y = x;
done = 0;
iter = 0;
% padding image to deal with pixels on borders
xPad = padarray(x,[height,width,0],'symmetric');
% build up look up table to boost computation speed
weight_map = exp( -(0:255^2)/hr^2 );
MS = [];
%% main loop
while ~done
    weightAccum = 0;
    yAccum = 0;
    for i = -hs:hs
        for j = -hs:hs
            if ( i~=0 || j~=0 )
                % spatial kernel weight 
                spatialKernel = 1;
                xThis =  xPad(height+i:2*height+i-1, width+j:2*width+j-1, 1:depth);
                xDiffSq = (y-xThis).^2;
                % feature kernel weight
                if isLuv
                    intensityKernel = repmat( prod( reshape( xDiffSq < hr^2, height, width, depth) , 3 ), [1,1, depth]);
                else
                    intensityKernel = repmat( prod( reshape( weight_map( xDiffSq+1 ), height, width, depth) , 3 ), [1,1, depth]);
                end
                % mixed kernel weight
                weightThis = spatialKernel.*intensityKernel;
                % update accumulated weights
                weightAccum = weightAccum+ weightThis;
                % update accumulated estimated ys from xs 
                yAccum = yAccum+xThis.*weightThis;
            end
        end
    end
    % normalized y (see Eq.(20) in the cited paper)
    yThis = yAccum./(weightAccum+eps);
    % convergence criterion
    yMS = mean(abs(round(yThis(:))-round(y(:))));
    y = round(yThis);    
    MS(iter+1) = yMS;
    %xPad = padarray(y,[height,width,0],'symmetric');
    if yMS/normFactor <= th % exit if converge
        done = 1;
    else % otherwise update estimated y and repeat mean shift
        iter = iter+1;
    end
end
if ~isLuv
    y = uint8(y);
end
