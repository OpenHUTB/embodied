%% *Train Humanoid Walker Using a Genetic Algorithm* 
% This example shows how to train a humanoid walker using <matlab: web(fullfile(docroot, 
% 'simulink/index.html')) Simulink™> and <matlab: web(fullfile(docroot, 'gads/index.html')) 
% Global Optimization Toolbox>. 
% 
% By default, this example shows a pre-trained humanoid walker. To train the 
% humanoid walker, set trainWalker=true. 

trainWalker=false;
%% 
% Load model parameters.

sm_humanoid_walker_ga_parameters
%% 
% Select model.

mdlName='sm_humanoid_walker_ga';
% Set Joint Optimization Options
% The genetic algorithm optimizes a vector of joint angle waypoints and a gait 
% period. The joint angle waypoints are optimized between -1 and 1, then scaled 
% in the controller to fit the corresponding joint range.
% 
% Set the number of joint angular waypoints in each joint pattern, and the range 
% of gait periods to search.

nPoints          = 4; 
gaitPeriodLimits = [0.5 2]; % (s)
%% 
% Set the upper and lower bounds for the optimization variables. The number 
% of variables is the number of angular demand values multiplied by the number 
% of joints in one leg, plus a variable for the gait period. Given this, formulate 
% the upper and lower bounds for each optimization variable.

ub        =  ones([1 nPoints*3]); % Angular demand values upper bound
lb        = -ub;                  % Angular demand values lower bound
ub(end+1) =  gaitPeriodLimits(2); % Gait period upper bound
lb(end+1) =  gaitPeriodLimits(1); % Gait period lower bound
% Set Genetic Algorithm Parameters
% Select genetic algorithm and set the parameters. Having a larger population 
% and more generations can produce better solutions but is more computationally 
% expensive.

opts                =  optimoptions('ga'); 
opts.MaxGenerations =  20;
opts.PopulationSize =  100;
opts.FitnessLimit   = -1000;
opts.Display        = 'iter';

plotOut=false; % Set true to plot progress
if plotOut
    opts.PlotFcns = @gaplotbestf;
end
%% 
% The <matlab: web(fullfile(docroot, 'parallel-computing/index.html')) Parallel 
% Computing Toolbox™> and <matlab: web(fullfile(docroot, 'simulink/ug/how-the-acceleration-modes-work.html')) 
% accelerator> simulation mode can be used to speed up optimization. 

parallelFlag     = true; 
accelFlag        = true;
opts.UseParallel = parallelFlag;
%% 
% Define the cost function.

costFcn = @(x)sm_humanoid_walker_sim_walking(x,mdlName,params);
%% Optimize Walking
% Load a pre-trained walker, or run the optimization by setting |trainWalker=t|rue. 
% Training using all speedup options with a six cores takes around 20 minutes. 

if trainWalker
    
    % Prepare for parallel simulation
    sm_humanoid_walker_ga_speedup; %#ok<UNRCH> 
    
    % Optimize walking 
    [x,fval,exitflag,output,population,scores] = ga(costFcn,length(ub),[],[],[],[],lb,ub,[],[],opts);
    
    % Clean up
    bdclose(mdlName)
    if parallelFlag
        delete(gcp('nocreate'))
        rmdir('temp','s');
    end

    % Save output
    fileName = ['humanoid_walker_ga_trained_', datestr(now,'mm-dd-yyyy HH-MM')];
    save(fileName, 'x','population','scores')
    
else
    
    % This is a pre-trained solution
    x = [0.9182    0.9441    0.6705   -0.2348   -0.2725   ...
        -1.0000   -0.9120    0.5830   -0.1476    0.5914   ...
        -0.5010   -0.7179    1.3537]; 
    nPoints = 4;
    
end
%Process solution
waypoints = sm_humanoid_walker_generate_waypoints(x(1:end-1),nPoints); 
gaitPeriod = x(end);
%% Simulate Solution
% Simulate the best individual.

open(mdlName)
sim(mdlName);
%% 
% _Copyright 2019-2020 The MathWorks, Inc._