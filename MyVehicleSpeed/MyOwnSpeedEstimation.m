clear
clc;

[filename, pathname] = uigetfile('*.*','Browse Video'); %select Input video
file = strcat(pathname, filename);
reader = vision.VideoFileReader(file);
fps = reader.info.VideoFrameRate;
Count = 0;
Time = 0;
coefficient = 0.00005;

% Create two video players, one to display the video,
% and one to display the foreground mask.
videoPlayer = vision.VideoPlayer('Name','VehicleDetection');

% Calibration Factor
blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false,  ...
    'OutputDataType', 'double','MinimumBlobArea', 100, 'MaximumBlobArea',3000);

% Vehicle Detection
vehicledetector = vision.CascadeObjectDetector('carclasshaar.xml','MinSize',...
    [50, 50],'MaxSize', [144, 144],'UseROI',true);
vehicledetector.MergeThreshold = 18;

tracks = initializeTracks();
nextId = 1; % ID of the next track

while ~isDone(reader)
    Count = Count + 1;
    [frame,frameg] = readFrame(reader);
    
    % Calculate Time 
    TimeperFrame = ((1./fps)./60)./60;
    Time = Time + TimeperFrame;
    
    [road_1,road_2,sobel] = detectRoad(frameg, blobAnalyser);
    BBoxvalue1{Count,:} = road_1;        
    BBoxvalue2{Count,:} = road_2;
    
    pixelD = roadwidth(sobel);
    pixelD(1,1) = pixelD; 
    calibrationf = (0.007./pixelD).*0.00005;
    
    if Count > 1
        [mydistance,Counter] = Calibration(Count,BBoxvalue1,BBoxvalue2);
        if ~isempty(mydistance)
            mydistance(1,1) = mydistance.*calibrationf;
            myspeed = mydistance./(TimeperFrame.*2);
            position = [400 373];
            label = ['My Speed: ' num2str(myspeed,'%0.1f') 'km/h'];
            Result = insertText(frame, position, label,'FontSize',50);
            step(videoPlayer, Result);
        end
    end
    
    [centroids,vehicle] = detectVehicle(frame, vehicledetector);
    predictNewLocationsOfTracks(tracks);
    [assignments, unassignedTracks, unassignedDetections] = ...
            detectionToTrackAssignment(tracks,centroids);
    tracks = updateAssignedTracks(tracks,centroids,vehicle, assignments);
    tracks = updateUnassignedTracks(tracks,unassignedTracks);
    tracks = deleteLostTracks(tracks);
    tracks = createNewTracks(centroids,vehicle,tracks,unassignedDetections,nextId);    
    vehicle = displayTrackingResults(tracks,vehicle);
    centroids = [(vehicle(:, 1) + vehicle(:, 3) / 2), ...
                         (vehicle(:, 2) + vehicle(:, 4) / 2)];
    centroids = round(centroids); 
    
    if ~isempty(centroids)
        TotalVehicle = size(centroids,1);
        label_str = cell(1,1);
        for k = 1 : TotalVehicle
            X{Count,k} = round(centroids(k,1));
            Y{Count,k} = round(centroids(k,2));
            
            if Count > 30
                Counter = Count - 29;
                [pixel_distance, DistancediffY] = distance(X,Y,k,Counter);
                acceleration = DistancediffY{Counter,k};
               
                distanceinkm = pixel_distance .* calibrationf;
                Speed = round(distanceinkm./(TimeperFrame .* 30));
                
                if acceleration < 0
                    trueSpeed{Counter,k} = Speed + myspeed;
                else
                    trueSpeed{Counter,k} = myspeed - Speed;
                end
                
                label_str{k} = [num2str(trueSpeed{Counter,k}) 'Km/h'];
                SpeedVisual = [vehicle(:, 1), vehicle(:, 2) + vehicle(:, 3)];
                if SpeedVisual(:,2) < 500 & SpeedVisual(:,2) > 460
                    frame = insertText(frame,SpeedVisual,label_str,'FontSize',18,'BoxOpacity',0.3); 
                end
            end 
        end
    end
    
    frame = im2uint8(frame);
    frame = insertObjectAnnotation(frame, 'rectangle', ...
                    vehicle, 'Vehicle');
        
    
    
        
end
                