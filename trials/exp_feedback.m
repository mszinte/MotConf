function exp_feedback(expDes)
% ----------------------------------------------------------------------
% exp_feedback(expDes)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute and display feedback on participant performances
% ----------------------------------------------------------------------
% Input(s) :
% expDes : struct containg experimental design
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Compute results
num_trials = size(expDes.expMat,1);
num_miss_resp_int1 = sum(round(expDes.expMat(:,9))==0);
ratio_miss_resp_int1 = num_miss_resp_int1 / num_trials;

num_miss_resp_int2 = sum(round(expDes.expMat(:,11))==0);
ratio_miss_resp_int2 = num_miss_resp_int2 / num_trials;

num_miss_resp_conf = sum(round(expDes.expMat(:,13))==0);
ratio_miss_resp_conf = num_miss_resp_conf / num_trials;

num_fix_break_int1 = sum(round(expDes.expMat(:,15))==0);
ratio_fix_break_int1  = num_fix_break_int1 / num_trials;

num_fix_break_int2 = sum(round(expDes.expMat(:,16))==0);
ratio_fix_break_int2  = num_fix_break_int2 / num_trials;

% Button press feedback
fprintf(1, '\n\tButton press feedback')
fprintf(1, '\n\t---------------------')
fprintf(1, '\n\tMissed reponse for 1st interval motion: %1.0f (%1.1f%% of run trials)', ...
    num_miss_resp_int1, ratio_miss_resp_int1*100)
fprintf(1, '\n\tMissed reponse of 2nd interval motion: %1.0f (%1.1f%% of run trials)', ...
    num_miss_resp_int2, ratio_miss_resp_int2*100)
fprintf(1, '\n\tMissed reponse of two intervals confidence: %1.0f (%1.1f%% of run trials)\n', ...
    num_miss_resp_conf, ratio_miss_resp_conf*100)

% Gaze position feedback
fprintf(1, '\n\tGaze position feedback')
fprintf(1, '\n\t----------------------')
fprintf(1, '\n\tFixation break during 1st interval motion: %1.0f (%1.1f%% of run trials)', ...
    num_fix_break_int1, ratio_fix_break_int1*100)
fprintf(1, '\n\tFixation break during 2nd interval motion: %1.0f (%1.1f%% of run trials)\n', ...
    num_fix_break_int2, ratio_fix_break_int2*100)

end