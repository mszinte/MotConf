function drawColorWheel(scr, const)
% ----------------------------------------------------------------------
% drawColorWheel(scr, const)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw bull's eye target
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

for rr = 1:const.direction_nb
    Screen('FrameArc', scr.main, const.ring_col_rgb_lst(rr, :), ... 
        const.color_wheel_rect, const.frame_startAngle_lst(rr), ...
        const.frame_arcAngle, const.frame_default_thick_pix, ...
        const.frame_default_thick_pix);
end