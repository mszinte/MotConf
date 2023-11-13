function expDes = designConfig(const)
% ----------------------------------------------------------------------
% expDes = designConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define experimental design
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Experimental random variables

% Var 1: signal probability of first interval
expDes.oneV = (1:length(const.prob_signal_lst))';
expDes.nb_var1 = length(const.prob_signal_lst);
% 01 = 40 %
% 02 = 70 %
% 03 = 100 %

% Var 2: signal probability of second interval
expDes.twoV = (1:length(const.prob_signal_lst))';
expDes.nb_var2 = length(const.prob_signal_lst);
% 01 = 40 %
% 02 = 70 %
% 03 = 100 %

% Rand 1: signal direction of first interval
expDes.oneR = (1:length(const.direction_dva_lst))';
expDes.nb_rand1 = length(const.direction_dva_lst);
% 01 = 45 deg
% 02 = 135 deg
% 03 = 225 deg
% 04 = 315 deg

% Rand 2: signal direction of second interval
expDes.twoR = (1:length(const.direction_dva_lst))';
expDes.nb_rand2 = length(const.direction_dva_lst);
% 01 = 45 deg
% 02 = 135 deg
% 03 = 225 deg
% 04 = 315 deg

% Experimental configuration :
expDes.nb_var = 4;
expDes.nb_rand = 2;
expDes.nb_repeat = 4;
expDes.nb_trials = expDes.nb_repeat * expDes.nb_var1 * expDes.nb_var2;

% Experimental loop
trialMat = zeros(expDes.nb_trials,expDes.nb_var);
ii = 0;
for rep = 1:expDes.nb_repeat
    for var1 = 1:expDes.nb_var1
        for var2 = 1:expDes.nb_var2
            ii = ii + 1;
            trialMat(ii, 1) = var1;
            trialMat(ii, 2) = var2;
        end
    end
end

trialMat = trialMat(randperm(expDes.nb_trials)', :);
for t_trial = 1:expDes.nb_trials
    rand_var1 = expDes.oneV(trialMat(t_trial,1), :);
    rand_var2 = expDes.twoV(trialMat(t_trial,2), :);
    
    randVal1 = randperm(numel(expDes.oneR)); 
    rand_rand1 = expDes.oneR(randVal1(1));
    randVal2 = randperm(numel(expDes.twoR)); 
    rand_rand2 = expDes.twoR(randVal2(1));
    
    expDes.expMat(t_trial,:) = [NaN, NaN, const.runNum, t_trial, ...
        rand_var1, rand_var2, rand_rand1, rand_rand2, NaN, NaN, NaN, ...
        NaN, NaN, NaN];
    
    % 01: trial onset
    % 02: trial duration
    % 03: run number
    % 04: trial number
    % 05: var1: 1st-interval signal probability
    % 06: var2: 2nd-interval signal probability
    % 07: rand1: 1st-interval signal direction
    % 08: rand2: 2nd-interval signal direction
    % 09: 1st-interval direction response
    % 10: 1st-interval reaction time
    % 11: 2nd-interval direction response
    % 12: 2nd-interval reaction time
    % 13: confidence response
    % 14: confidence reaction time
    
end

end