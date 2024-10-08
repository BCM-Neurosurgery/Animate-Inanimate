%% DESCRIPTION
% Function called by: main.m
% Role of function is to begin the program, initiate parameters, start the Screen and Audio  
% Returns all the parameters that might be needed for the program to run the trials  
% Input: None
% Output: 
%   - parameters: parameters to be used for the experiment

%% CODE
function parameters = Start_Up()
    % Clear the command line and the screen
    sca;
    close all;
    clc;
    
    % Generate the parameters that will be used in the experiment
    parameters = Insert_Params();
    
    % The saving Directory probably does not exist, so create it.
    disp(parameters.outputDir);
    if ~exist(parameters.outputDir, "dir"); mkdir(parameters.outputDir); end
    
    % Initialize the Screen
    Set_Up_Screen(parameters);

    % Initialize the Sound
    % parameters.audio = struct;
    % parameters.audio = SetUpAudio(parameters.audio);
end

%% CHANGELOG 
% Georgios Kokalas Spring/Summer 2024
%   - Created and Adjusted the file

% Georgios Kokalas 9th Sept. 2024
%   - Altered implementation of Insert_Params
%   - Changed Naming Conventions