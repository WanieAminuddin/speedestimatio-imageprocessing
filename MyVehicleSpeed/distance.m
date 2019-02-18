function [pixel_distance, DistancediffY] = distance(X,Y,k,Counter)
    for s = 1 : Counter 
        DistancediffX{Counter,k} = single(X{s+29,k}) - single(X{s,k});
        DistancediffY{Counter,k} = single(Y{s+29,k}) - single(Y{s,k});
        
        pixel_distance = hypot(single(DistancediffX{Counter,k}), single(DistancediffY{Counter,k}));                
    end
end