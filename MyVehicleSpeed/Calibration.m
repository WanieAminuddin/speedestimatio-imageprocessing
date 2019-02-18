function  [mydistance,Counter] = Calibration(Count,BBoxvalue1,BBoxvalue2)
    Counter = Count - 1;
    for s = 1 : Counter 
        CX{Counter,:} = single(BBoxvalue1{s+1,:}) - single(BBoxvalue1{s,:});
        CY{Counter,:} = single(BBoxvalue2{s+1,:}) - single(BBoxvalue2{s,:});                        
        mydistance = hypot(single(CX{Counter,:}), single(CY{Counter,:}));
    end
end