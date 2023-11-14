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

% TODO
% ----
% - make training
% - make fixation stimulus
% - copy color wheel stimulus
% - copy motion stimulus
% - Make instructions image
% - check _eventfile values
% - check timing
% - make training with visual feebacks for scanner
% - Check screen settings in 3T room
% - Check daq replacement statements and button box in 3T room
% - make movie

% First settings
Screen('CloseAll'); clear all; clear mex; clear functions; close all; ...
    home;AssertOpenGL;

% General settings
const.expName = 'MotConf';      % experiment name
const.expStart = 0;             % Start of a recording (0 = NO, 1 = YES)
const.checkTrial = 1;           % Print trial conditions (0 = NO, 1 = YES)
const.mkVideo = 0;              % Make a video (0 = NO, 1 = YES)

% External controls
const.tracker = 0;              % run with eye tracker (0 = NO, 1 = YES)
const.scanner = 0;              % run in MRI scanner (0 = NO, 1 = YES)
const.scannerTest = 0;          % fake scanner trigger (0 = NO, 1 = YES)
const.training = 0;             % training session (0 = NO, 1 = YES)

% Desired screen setting
const.desiredFD = 120;          % Desired refresh rate
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