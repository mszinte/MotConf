function drawBullsEye(scr, const, coordX, coordY, colorRGB, type)
% ----------------------------------------------------------------------
% drawBullsEye(scr, const, coordX, coordY, colorRGB, type)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw bull's eye target
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% coordX: bull's eye coordinate X
% coordY: bull's eye coordinate Y
% type : bull's eye type ('conf': confidence judgment period, 
%                         'int1': 1st-interval motion judgment period, 
%                         'int2': 2nd-interval motion judgment period)
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

if strcmp(type, 'conf')
    % full dot
    Screen('DrawDots', scr.main, [coordX, coordY], ...
        const.fix_out_rim_rad*2, colorRGB , [], 2);
elseif strcmp(type, 'int1')
    % one ring bull's eye
    Screen('DrawDots', scr.main, [coordX, coordY], ...
        const.fix_out_rim_rad*2, colorRGB , [], 2);
    Screen('DrawDots',scr.main, [coordX, coordY], ...
        const.fix_rim_rad*2, const.background_color , [], 2);
elseif strcmp(type, 'int2')
    % two rings bull's eye
    Screen('DrawDots', scr.main, [coordX, coordY], ...
        const.fix_out_rim_rad*2, colorRGB , [], 2);
    Screen('DrawDots',scr.main, [coordX, coordY], ...
        const.fix_rim_rad*2, const.background_color , [], 2);
    Screen('DrawDots',scr.main, [coordX, coordY], ...
        const.fix_rad*2, colorRGB, [], 2);
end
end
