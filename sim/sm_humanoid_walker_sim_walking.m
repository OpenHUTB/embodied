%% Simulate walking and Calculate Reward

% Copyright 2019-2022 The MathWorks, Inc.

function R = sm_humanoid_walker_sim_walking(x,mdlName,params)


nPoints=(length(x)-1)/3;
waypoints = sm_humanoid_walker_generate_waypoints(x(1:end-1),nPoints);
gaitPeriod=x(end);

mdlWks = get_param(mdlName,'ModelWorkspace');
assignin(mdlWks,'gaitPeriod',gaitPeriod)
assignin(mdlWks,'nPoints',nPoints)
assignin(mdlWks,'waypoints',waypoints)

simOut = sim(mdlName,'FastRestart','on','SrcWorkspace','current');
R=-sum(simOut.yout{1}.Values.Data); 

end

