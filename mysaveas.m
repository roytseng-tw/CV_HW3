function [ ] = mysaveas(fig, filename)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    frame = getframe(fig);
    snapshot = frame2im(frame);
    imwrite(snapshot, filename);
end

