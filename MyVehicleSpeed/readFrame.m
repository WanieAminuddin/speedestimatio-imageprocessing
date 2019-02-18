function [frame,frameg] = readFrame(reader)
    frame = step(reader); 
    frameg = rgb2gray(frame);
    H2 = fspecial('disk',4);
    frameg = imfilter(frameg,H2,'replicate');
end