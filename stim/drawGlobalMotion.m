function drawGlobalMotion(scr, const, dtst, gabor_orient, mypars)
% ----------------------------------------------------------------------
% drawGlobalMotion(scr, const, stim_ori, mot_prob, mot_dir)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw global motion patterns
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% stim_ori : stimulus whole orientation
% stim_prob : motion signal probability
% mot_dir : motion signal direction
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

  Screen('DrawTextures', scr.main, scr.gabortex, [], dtst, gabor_orient, ...
    [], [], [], [], kPsychDontDoRotation, mypars);

end