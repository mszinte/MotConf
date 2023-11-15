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

% Var 2: signal probability of second interva
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
expDes.nb_repeat = const.nb_repeat;

% Experimental loop
trialMat = zeros(const.nb_trials,expDes.nb_var);
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

trialMat = trialMat(randperm(const.nb_trials)', :);
for t_trial = 1:const.nb_trials
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



% pre-allocation

expDes.issignalS = NaN(const.nb_trials, 2, const.gabor_count);
expDes.intended_global_dirS = NaN(const.nb_trials, 2, const.gabor_count);
expDes.gabor_orient_degS = NaN(const.nb_trials, 2, const.gabor_count);
expDes.gabor_speed_incS = NaN(const.nb_trials, 2, const.gabor_count);
expDes.gabor_phase_lst = NaN(const.nb_trials, 2, const.gabor_count);


% calculate all fixed parameters of Gabors for each Trials
% -> randomize Gabor orientations
expDes.gabor_orient_degS = (randi([0, 4294967295],[const.nb_trials,2, const.gabor_count]) ./ 4294967296).*180;
% -> randomize Gabor phases
expDes.gabor_phase_lst = (randi([0, 4294967295],[const.nb_trials,2, const.gabor_count]) ./ 4294967296).*360;


% ========================================================================
for tt = 1:const.nb_trials
    target_dir_lst_deg(1)=const.direction_dva_lst (expDes.expMat(tt,7));
    target_dir_lst_deg(2)=const.direction_dva_lst (expDes.expMat(tt,8));
    prob_signal_intrvl(1)=const.prob_signal_lst(expDes.expMat(tt,5));
    prob_signal_intrvl(2)=const.prob_signal_lst(expDes.expMat(tt,6));
    
    % -> generate stimuli for the two intervals
    for intrvl = 1:2
        
        % -> generate local speed value for each Gabor
        nb_signal = 0;
        for gg = 1:const.gabor_count
            gab_ori = expDes.gabor_orient_degS(tt,intrvl, gg);
            % -> does this Gabor belong to target?
            is_signal (gg) = (rand <= prob_signal_intrvl(intrvl));
            
            if (is_signal(gg))
                nb_signal = nb_signal + 1;
                intended_global_dir(gg) = target_dir_lst_deg(intrvl);
            else
                % -> if noise, assign random intended global motion direction
                intended_global_dir(gg) = (randi([0, 4294967295]) ./ 4294967296)*360;
            end
            angle_diff_deg = gab_ori - intended_global_dir(gg);
            vect_len = cos(angle_diff_deg * (pi/180));  % vector length
            gabor_speed_inc(intrvl, gg) = const.gabor_speed_phadeg_frm  * vect_len;
        end
        %save the stim parameters
        expDes.issignalS(tt,intrvl,:)=is_signal;
        expDes.intended_global_dirS(tt,intrvl,:)=intended_global_dir;
    end
    expDes.gabor_speed_incS(tt,:,:)=gabor_speed_inc;
end

