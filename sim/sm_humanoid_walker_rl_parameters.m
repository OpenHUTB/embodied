%% Humanoid Walker With Reinforcement Learning Intialization
% Copyright 2019 The MathWorks, Inc.

%% Joint rotation limits
%These limits are similar to human joint rotation limits. 

% Legs= joints
params.jointLimits.hipFrontalUpperLimit  =  30;  % (Deg)
params.jointLimits.hipFrontalLowerLimit  = -90;  % (Deg)
params.jointLimits.kneeUpperLimit        =  90;  % (Deg)
params.jointLimits.kneeLowerLimit        =  5;   % (Deg)
params.jointLimits.ankleUpperLimit       =  20;  % (Deg)
params.jointLimits.ankleLowerLimit       = -20;  % (Deg)
% Arm joints
params.jointLimits.shoulderFrontalUpperLimit        =  110; % (Deg)
params.jointLimits.shoulderFrontalLowerLimit        = -30;  % (Deg)
params.jointLimits.shoulderSagittalUpperLimit       =  90;  % (Deg)
params.jointLimits.shoulderSagittalLowerLimit       = -30;  % (Deg)

%% Material properties

params.materialProperties.lowerBodyDensity = 990;  % (kg/m^3)
params.materialProperties.upperBodyDensity = 1900; % (kg/m^3)

%% World damping
% We add damping to the vertical (z) and rotational (Rx, Ry, Rz) components
% of the bushing joint. This dissipates energy from the system and facilates 
% quicker learning. Increasing this improves stability and learning, but is
% less realistic. 

params.simulation.worldDamping = 6; % (Ns/m)

%% Simulation parameters

params.simulation.initialHeight=1.54; % (m) Intial height of robot
params.simulation.Ts = 0.025;         % (s) Control and sensing discretization time
params.simulation.Tf = 60;      % (s) Max simulation time

%% Spatial contact force block parameters. 
% The value of these parameters affects simulation and learning speed. 
% Higher damping generally improves learning but slows down simulation. 
% High static and dynamic friction values tend to improve learning. 

params.contact.stiffness        = 1e5;  % (N/m)
params.contact.damping          = 1e5;  % (Ns/m) 
params.contact.transitionWidth  = 1e-3; % (m)
params.contact.staticFriction   = 1;    % () 
params.contact.dynamicFriction  = 0.9;  % ()
params.contact.criticalVelocity = 1e-3; % (m/s) 
params.contact.contactRadius = 0.01;    % (m)

%% Controller parameters

params.controller.hipFrontalStiffness  = 80; % (N*m/rad)
params.controller.hipFrontalDamping    = 1;  % (N*m*s/rad)
params.controller.kneeStiffness        = 80; % (N*m*/rad)
params.controller.kneeDamping          = 1;  % (N*m*s/rad)
params.controller.ankleStiffness       = 80; % (N*m/rad)
params.controller.ankleDamping         = 1;  % (N*m*s/rad)

params.torqueLimits.hipFrontal  = 100; % (N*m)
params.torqueLimits.knee        = 100; % (N*m)
params.torqueLimits.ankle       = 100; % (N*m)

%% Stopping criteria
% Define the conditions under which the simulation is terminated early. 
% One or more of three conditions need to be satisfied for termination. 
% If the humanoid torso drops vertically, travels laterally or rotates in
% any axis more than a set of predefined values, or if the humanoid stops
% moving.

params.stoppingCriteria.heightChange     = 0.5; % (m)
params.stoppingCriteria.lateral          = 1;   % (m)
params.stoppingCriteria.angle            = 30;  % (deg)
params.stoppingCriteria.timeoutTime      = 2;   % (s)
params.stoppingCriteria.timeoutDistance  = 1;   % (m)

%% Reward scaling parameters

params.reward.forwardRewardWeight   = 1;    % Forward velocity scale, w_1
params.reward.timestepRewardWeight  = 1;    % Not falling scale, w_2
params.reward.powerPenaltyWeight    = 5e-4; % Power scale, w_3
params.reward.verticalPenaltyWeight = 25;   % Vertical displacement scale, w_4
params.reward.lateralPenaltyWeight  = 5;  % Lateral displacement scale, w_5

%% Display parameters 

params.display.tileColour    = [0.956, 0.941, 0.941];
params.display.floorColour   = [0.756, 0.741, 0.741];
params.display.tileThickness = 0.005; 
params.display.planeWidth        = 2;   % (m)
params.display.planeLength       = 50;  % (m)
params.display.planeHeight       = 1;   % (m)



