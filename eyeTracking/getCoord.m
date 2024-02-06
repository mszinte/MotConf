function [x, y, t] = getCoord(eyetrack)
% ----------------------------------------------------------------------
% [x, y, t] = getCoord(eyetrack)
% ----------------------------------------------------------------------
% Goal of the function :
% Get gaze coordinates of the eyetracker
% ----------------------------------------------------------------------
% Input(s) :
% eyetrack : structure containing eyetracking configurations
% ----------------------------------------------------------------------
% Output(s):
% x: X eye coordinate (horizontal)
% y: Y eye coordinate (vertical)
% t: eyetracker time machine
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

evt = Eyelink('newestfloatsample');
x = evt.gx(eyetrack.recEye);
y = evt.gy(eyetrack.recEye);
t = evt.time;
if evt.gx(eyetrack.recEye) == -32768 || evt.gy(eyetrack.recEye) == -32768
    x = NaN;
    y = NaN;
end

end