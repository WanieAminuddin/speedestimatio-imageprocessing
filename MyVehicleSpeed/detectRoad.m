function [road_1,road_2,sobel] = detectRoad(frameg,blobAnalyser)
    hy = fspecial('sobel');   
    sobelroad = imfilter(double(frameg), hy, 'replicate');
    level = graythresh(sobelroad);
    sobel = im2bw(sobelroad,level);

    [Height, Width] = size(sobel);
    P1 = [200,Height-100];
    P2 = [425,490];
    P3 = [Width-425 ,490];
    P4 = [Width-200,Height-100];

    First = [P1(1), P2(1), P3(1), P4(1)];
    Second = [P1(2), P2(2), P3(2), P4(2)];

    binaryMask = roipoly(sobel, First,Second);
    road = sobel.*cast(binaryMask,class(sobel)); %multiply
    road = imfill(road, 'holes');
    CC = bwconncomp(road);
    S = regionprops(CC, 'Perimeter', 'Area');
    L = labelmatrix(CC);
    idx = find([S.Perimeter] > 130 & [S.Perimeter] <= 350 & [S.Area] > 250);    
    road2 = ismember(L, idx);
    road2 = bwareafilt(road2,1);

    road2 = step(blobAnalyser, road2);
    road2 = (round(road2));
    road_1 = road2(:,1);
    road_2 = road2(:,2);
end