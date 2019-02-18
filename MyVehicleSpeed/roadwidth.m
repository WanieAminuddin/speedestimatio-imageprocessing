function pixelD = roadwidth(sobel)
    [Height, Width] = size(sobel);
    P1 = [1,Height-100];
    P2 = [1,490];
    P3 = [Width ,490];
    P4 = [Width,Height-100];

    First = [P1(1), P2(1), P3(1), P4(1)];
    Second = [P1(2), P2(2), P3(2), P4(2)];

    binaryMask = roipoly(sobel, First,Second);
    sobel = sobel.*cast(binaryMask,class(sobel)); %multiply
    %%    
    % Hough Transform
    [H,theta,rho] = hough(sobel);
    % Finding the Hough peaks (number of peaks is set to 10)
    P = houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));
    x = theta(P(:,2));
    y = rho(P(:,1));

    %Fill the gaps of Edges and set the Minimum length of a line
    lines = houghlines(sobel,theta,rho,P,'FillGap',100,'MinLength',50);
    refline = [0, 530, Width, 530];
    structSize = length(lines);
 
    if structSize > 1    
        xy = [lines(1).point1, lines(1).point2];
        xy2 = [lines(2).point1, lines(2).point2];

        xpoint = [xy(1), xy(3),xy2(1), xy2(3)];
        ypoint = [xy(2), xy(4),xy2(2), xy2(4)];

        xpointref = [refline(1), refline(3)];
        ypointref = [refline(2), refline(4)];

        [xi, yi] = polyxpoly(xpoint, ypoint, xpointref, ypointref);
        DdiffX = xi(1) - xi(2);
        DdiffY = yi(1) - yi(2);
        pixelD = hypot(single(DdiffX), single(DdiffY)); 
    end
end