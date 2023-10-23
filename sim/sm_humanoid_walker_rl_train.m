%% *Train Humanoid Walker Using Reinforcement Learning*
% This example shows how to train a humanoid walker using <matlab: web(fullfile(docroot, 
% 'deeplearning/index.html')) Deep Learning Toolbox™ >and <matlab: web(fullfile(docroot, 
% 'reinforcement-learning/index.html')) Reinforcement Learning Toolbox™>.
% 
% By default, this example shows a pre-trained humanoid walker. To train the 
% humanoid walker, set trainWalker=true. 

trainWalker=false;
% Initialization
% Add path to supporting files.
% 
% Load model parameters.

sm_humanoid_walker_rl_parameters
%% 
% Select model.

mdlName='sm_humanoid_walker_rl';
load_system(mdlName);
% Set objective function 
% An objective function is used to evaluate different walking styles. A reward 
% ($r_t$) is given at each timestep, based on the following factors
%% 
% # Forward velocity ($v_y$ ) is rewarded
% # Not falling over is rewarded
% # Power consumption ($p$)  is penalized
% # Vertical displacement ($\Delta z$)  is penalized.
% # Lateral displacement ($\Delta x$) is penalized. 
%% 
% The total reward at each timestep is
% 
% $$r_t =w_{1\;} v_{y\;} +w_2 T_s -w_{3\;} p-w_{4\;} \Delta z-w_{5\;} \Delta 
% x$$
% 
% where $T_s$ is the agent timestep and $w_{1,\ldotp \ldotp \ldotp ,5}$ are 
% weights which represent the relative importance of each term in the reward function. 
% Hence, the total reward ($R$) for a walking trial is
% 
% $$R=\sum_{t=0}^T r_{t\;}$$
% 
% where $T$ is the time at which the simulation terminates. The reward weights 
% can be changed in the <matlab: open('sm_humanoid_walker_rl_parameters') sm_humanoid_walker_rl_parameters> 
% script. 
% 
% The simulation terminates if the simulation time has been reached, or the 
% robot falls. This is defined as:
%% 
% # The robot dropping below 0.5 m
% # The robot moving laterally by more than 1 m
% # The robot torso rotating by more than 30 deg
%% 
% These criteria can be changed in the <matlab: open('sm_humanoid_walker_rl_parameters') 
% sm_humanoid_walker_rl_parameters> script. 
% Create RL environment
% Create an RL environment. In a reinforcement learning scenario, where you 
% are training an agent to complete task, the environment models the dynamics 
% with which the agent interacts. 
% 
% We have 6 actions, one input for each joint.

numAct          = 6; % 6 joints
actionInfo      = rlNumericSpec([numAct 1],'LowerLimit',-1,'UpperLimit', 1);
actionInfo.Name = 'jointDemands';
%% 
% Define the number of state observations, number of possible actions and action 
% upper and lower  limits. In our model, we have 25 state measurements. We also 
% include the previous action as an observation, so the total number of observations 
% is 31.

numObs               = 25+6; % 25 sensors, 6 previous actions
observationInfo      = rlNumericSpec([numObs 1]);
observationInfo.Name = 'observations';
%% 
% Finally, define the environment and point to the RL Agent block. 

% Define environment
load_system(mdlName);
blk = [mdlName,'/RL Agent'];
env = rlSimulinkEnv(mdlName,blk,observationInfo,actionInfo);
% Create actor and critic networks
% A DDPG agent approximates the long-term reward given observations and actions 
% using a critic value function representation. To create the critic, first create 
% a deep neural network with two inputs, the state and action, and one output. 
% For more information on creating a deep neural network value function representation, 
% see <https://www.mathworks.com/help/reinforcement-learning/ug/create-policy-and-value-function-representations.html 
% Create Policy and Value Function Representations>.

actorLayerSizes =  [400 300]; % Actor network layer sizes
criticLayerSizes = [400 300]; % Critic network layer sizes
sm_humanoid_walker_create_networks; % Create networks 

criticOptions = rlRepresentationOptions('Optimizer','adam','LearnRate',1e-3,... 
                                        'GradientThreshold',1,'L2RegularizationFactor',2e-4);
actorOptions  = rlRepresentationOptions('Optimizer','adam','LearnRate',1e-4,...
                                       'GradientThreshold',1,'L2RegularizationFactor',1e-5);
% Set rlDDPG agent options
% First, we set the RL agent options. These parameters affect how the agent 
% behaves and learns, and choosing correct values is important for sucessful RL 
% use. <matlab: doc rlDDPGAgentOptions Read more about DDPG agent options here.>

agentOptions                                     = rlDDPGAgentOptions;
agentOptions.SampleTime                          = params.simulation.Ts;
agentOptions.DiscountFactor                      = 0.99; 
agentOptions.MiniBatchSize                       = 128;
agentOptions.ExperienceBufferLength              = 1e6; 
agentOptions.TargetSmoothFactor                  = 1e-3;
agentOptions.NoiseOptions.MeanAttractionConstant = 5;
agentOptions.NoiseOptions.Variance               = 0.4;
agentOptions.NoiseOptions.VarianceDecayRate      = 1e-5;
% Create rlDDPG Agent
% Create the DDPG agent using the specified actor representation, critic representation 
% and agent options. For more information, see <https://www.mathworks.com/help/reinforcement-learning/ref/rlddpgagent.html 
% |rlDDPGAgent|>.

agent = rlDDPGAgent(actor,critic,agentOptions);
% Set RL training options
% To train the agent, first specify the training options. For this example, 
% use the following options:
%% 
% * Run training for at most 3000 episodes, with each episode lasting at most 
% 4|00| time steps.
% * Display the training progress in the Episode Manager dialog box (set the 
% |Plots| option) and disable the command line display (set the |Verbose| option).
% * Stop training when the agent receives an average cumulative reward greater 
% than 1000 over five consecutive episodes. At this point, the agent can quickly 
% balance the pendulum in the upright position using minimal control effort.
% * Save a copy of the agent for each episode where the cumulative reward is 
% greater than 1000.
%% 
% For more information, see <https://www.mathworks.com/help/reinforcement-learning/ref/rltrainingoptions.html 
% |rlTrainingOptions|>.

useFastRestart = true; 
useParallel    = true;

trainingOptions                            = rlTrainingOptions;
trainingOptions.MaxEpisodes                = 4000;
trainingOptions.MaxStepsPerEpisode         = params.simulation.Tf/params.simulation.Ts;
trainingOptions.ScoreAveragingWindowLength = 100;
trainingOptions.SaveAgentCriteria          = 'EpisodeReward';
trainingOptions.SaveAgentValue             = 500;
trainingOptions.Plots                      = 'training-progress';
trainingOptions.Verbose                    = true;
trainingOptions.StopOnError                = 'off';
trainingOptions.StopTrainingCriteria       = 'AverageReward';
trainingOptions.StopTrainingValue          = 1000;

if ~useFastRestart
   env.UseFastRestart = 'off'; 
end

if useParallel
    trainingOptions.Parallelization = 'async';
    trainingOptions.ParallelizationOptions.StepsUntilDataIsSent = -1;
end    
%% Train humanoid walker
% Train the agent using the <https://www.mathworks.com/help/reinforcement-learning/ref/rl.agent.rlqagent.train.html 
% |train|> function. Training this agent is a computationally intensive process 
% that takes several hours to complete. To save time while running this example, 
% load a pretrained agent by setting |doTraining| to |false|. To train the agent 
% yourself, set |doTraining| to |true|.

if trainWalker
    
    trainingResults = train(agent,env,trainingOptions); %#ok<UNRCH> 
    
    reset(agent); % Clears the experience buffer
    curDir = pwd;
    saveDir = 'savedAgents';
    cd(saveDir)
    save(['humanoid_walker_rl_trained_' datestr(now,'mm_DD_YYYY_HHMM')],'agent','trainingResults');
    cd(curDir)
    
    bdclose(mdlName)
    if useParallel
        delete(gcp('nocreate'));
    end
    env = rlSimulinkEnv(mdlName,blk,observationInfo,actionInfo);
else
    load('sm_humanoid_walker_saved_agent')
    agent=saved_agent;
end
% Simulate DDPG Agent
% To validate the performance of the trained agent, simulate it within the pendulum 
% environment. For more information on agent simulation, see <https://www.mathworks.com/help/reinforcement-learning/ref/rlsimulationoptions.html 
% |rlSimulationOptions|> and <https://www.mathworks.com/help/reinforcement-learning/ref/rl.env.abstractenv.sim.html 
% |sim|>.

open(mdlName)
simOpts = rlSimulationOptions('MaxSteps',60/agentOptions.SampleTime);
experience=sim(env,agent,simOpts);