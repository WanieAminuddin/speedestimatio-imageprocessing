function [centroids,vehicle] = detectVehicle(frameg, vehicledetector)
    % Detect vehicle.
    vehicle = step(vehicledetector, frameg, [50,360,1180,360]);
    % Calculate centroid
    % Center of X
    Centroidx = vehicle(:,1) + (vehicle(:,3)/2);
    % Center of Y
    Centroidy = vehicle(:,2) + (vehicle(:,4)/2);
    centroids = [Centroidx,Centroidy];     
end