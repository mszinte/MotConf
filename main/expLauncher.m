%% General experimenter launcher
%  =============================
% By: Martin SZINTE
% Projet: MotConf
% With: Can OLUK, Pascal MAMASSIAN & Guillaume MASSON

% Version description
% -------------------
% Experiment in which participant judge global motion direction in two
% trials before determining which of the two judgmeent they were more
% confident about.

% TODO (martin)
% -------------
% - make movie
% - make training
% - check _eventfile values
% - Check screen settings in 3T room
% - Check daq replacement statements and button box in 3T room


% TODO (martin)
% -------------
% - check problem with windmill 
% - check timing
% - check difference with different Screen('BlendFunction') settings

% First settings
Screen('CloseAll'); clear all; clear mex; clear functions; close all; ...
    home;AssertOpenGL;

% General settings
const.expName = 'MotConf';      % experiment name
const.expStart = 1;             % Start of a recording (0 = NO, 1 = YES)
const.checkTrial = 0;           % Print trial conditions (0 = NO, 1 = YES)
const.mkVideo = 0;              % Make a video (0 = NO, 1 = YES)

% External controls
const.tracker = 0;              % run with eye tracker (0 = NO, 1 = YES)
const.comp = 1;                 % run in which computer (1 = MRI; 2 = Can laptop; 3 = Diplay++)
const.scanner = 1;              % run in MRI scanner (0 = NO, 1 = YES)
const.scannerTest = 1;          % fake scanner trigger (0 = NO, 1 = YES)
const.training = 0;             % training session (0 = NO, 1 = YES)
const.run_total = 5;            % number of run in total

% Desired screen setting
const.desiredFD = 60;          % Desired refresh rate
const.desiredRes = [1920,1080]; % Desired resolution

% Path
dir = which('expLauncher');
cd(dir(1:end-18));

% Add Matlab path
addpath('config', 'main', 'conversion', 'eyeTracking', 'instructions',...
    'trials', 'stim');

% Subject configuration
const = sbjConfig(const);

% Main run
main(const);