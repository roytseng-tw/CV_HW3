%	input name
inputName = 'jaguar.avi';

%   output name
outputName = 'jaguar_gray.avi';

%   Create object to read video files 
video1 = VideoReader(inputName);

%   info of input video
nFrames = video1.NumberOfFrames;
vidHeight = video1.Height;
vidWidth = video1.Width;

%   Create object to write video files 
video2 = VideoWriter(outputName);

open(video2);
for k = 1 : nFrames
    % read the k-th frame of input video
    I = read(video1, k);
    
    % write data from an array to the video
    writeVideo(video2, rgb2gray(I));
end
close(video2)