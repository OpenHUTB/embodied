%% Humanoid Walker Speedup Tasks for Parallel Optimisation
% Copyright 2019 The MathWorks, Inc.

disp('Humanoid walker speedup tasks starting....')

load_system(mdlName)
 
if parallelFlag
    % Create a parallel pool
    if isempty(gcp('nocreate'))
        parpool; % Uses default saved profile
    else
        delete(gcp('nocreate'))
        parpool;
    end
    % Switch all workers to a separate tempdir in case %any code is generated
    % for instance for StateFlow, or any other file artifacts are  created by the model.
    rootDir = pwd;
    parfevalOnAll(@addpath,0,rootDir);
    parfevalOnAll(@load_system,0,mdlName);
    parfevalOnAll(@set_param,0,mdlName,'SimMechanicsOpenEditorOnUpdate','off');
    
    % Set accelerator mode if selected
    if accelFlag
        parfevalOnAll(@set_param,0,mdlName,'SimulationMode','accelerator');
    end
    
    % Change each worker to unique folder so cache files do not conflict
    cd(fullfile(rootDir));
    if exist('temp','dir')
        rmdir('temp','s');
    end
    mkdir('temp');
    spmd
        tempFolder = fullfile(rootDir,'temp');
        cd(tempFolder);
        folderName = tempname(tempFolder);
        mkdir(folderName);
        cd(folderName)
    end
    pctRunOnAll warning off 
else
    % Set accelerator mode if selected
    if accelFlag
        set_param(mdlName,'SimulationMode','accelerator');
        set_param(mdlName,'SimMechanicsOpenEditorOnUpdate','off');
    end
end

