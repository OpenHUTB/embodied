%% Convert optimsation variable vector to waypoints values and triggers
% Copyright 2019 The MathWorks, Inc.

function [waypoints] = sm_humanoid_walker_generate_waypoints(x,nPoints)

value=[];
for i=1:3
    value(i,:)=x(1:nPoints);
    x(1:nPoints)=[];
end

trigger=[];
for i=0:(nPoints-1)
    trigger(i+1)=i*1/nPoints;
end

waypoints.value=value;
waypoints.trigger=trigger;
end

