% motion confidence experiment
%
% uses some elements from PsychToolbox demo: 'ProceduralGarboriumDemo'
% 14-JAN-2022 -- pascal mamassian
% 24-JAN-2022 -- pm: added CFC
% 1-MARC-2023 -- fine tune, can
% 1-MAY-2023 -- eye tracking


clear all;
close all;

% DEBUG CODE!
ExpSettings.screenWarnings = 0;
ExpSettings.run_on_laptop = 1;


% INPUT_PARTICIPANT
ExpSettings.subjectName = input('Participant Initials: ','s');    % default subject name
% -> Is Training session?
ExpSettings.print_instructions = input('0 for Real Data, 1 for the training: ');

if ExpSettings.print_instructions ==1
    ExpSettings.subjectName=strcat(ExpSettings.subjectName,'T');
end

% -> Is there previous data?
if ~strcmp(ExpSettings.subjectName,'tst') && ~strcmp(ExpSettings.subjectName,'tstT')
    if isfile(strcat(ExpSettings.subjectName,'TMP.mat'))
        % File exists.
        flagFORdataContinue=1;
    else
        % File does not exist.
        flagFORdataContinue=0;
    end
else
    flagFORdataContinue=0;
end


% SET
[ExpSettings.seed, ExpSettings.whichGen] = ClockRandSeed;	% Seed random number generator
ListenChar(2);                      % Disable transmission of keypresses to Matlab



% ========================================================================
% -> Experiment details
ExpSettings.gammaM=2;
ExpSettings.viewingDistance = 573;			% viewing distance in mm

if (ExpSettings.run_on_laptop)
    % ExpSettings.resolDesired = [1792, 1120];		% laptop default <<
    % ExpSettings.resolDesired = [1440, 900];		% old laptop default
    %ExpSettings.resolDesired = [1680, 1050];		% laptop small
    ExpSettings.resolDesired = [1920, 1080];		% laptop default CAN
else
    ExpSettings.resolDesired = [1280, 1024];		% CRT @ 60Hz
end

if (eq(ExpSettings.resolDesired, [1792, 1120]))
    ExpSettings.dotPitch = 0.192;           % pixel size in mm (for 1792 x 1120)
elseif (eq(ExpSettings.resolDesired, [1024, 768]))
    ExpSettings.dotPitch = 0.273;           % pixel size in mm (for 1024 x 768)
elseif (eq(ExpSettings.resolDesired, [1440, 900]))
    ExpSettings.dotPitch = 0.230;           % pixel size in mm (for 1440 x 900)
elseif (eq(ExpSettings.resolDesired, [1680, 1050]))
    ExpSettings.dotPitch = 0.197;           % pixel size in mm (for 1680 x 1050)
elseif (eq(ExpSettings.resolDesired, [1920, 1080])) % Can pc, 30 for big screen
    ExpSettings.dotPitch = 0.30;           % pixel size in mm (for 1920 x 1080), 30
elseif (eq(ExpSettings.resolDesired, [1280, 1024])) % CRT
    ExpSettings.dotPitch = 0.2754;           % pixel size in mm (for 1280 x 1024), mean([35.5*10/1280, 28*10/1024])
else
    ExpSettings.dotPitch = 0.25;            % default (arbitrary) dot pitch
end

if (ExpSettings.run_on_laptop)
    refreshRateDesired = 60;		% desired refresh rate (Hz)
else
    refreshRateDesired = 60;		% desired refresh rate (Hz)
end


ExpSettings.fps = refreshRateDesired ;     % number of frames per second
msecTOfr = ExpSettings.fps / 1000; % msec to frames
frTOmsec = 1000 / ExpSettings.fps; % frames to msec

DTOR = pi/180;      % conversion degrees to radians
RTOD = 180/pi;      % conversion radians to degrees
pixTOdeg = atan(ExpSettings.dotPitch/ExpSettings.viewingDistance)*RTOD; % conversion pixels to degrees
ExpSettings.degTOpix = 1/pixTOdeg;  % conversion degrees (vis. angle) to pixels

% ========================================================================

% -> **************************************
% -> stimulus parameters

% -> movie frames
total_duration_msec = 1000;              % total stimulus duration (msec)
ExpSettings.total_duration_fr = total_duration_msec * msecTOfr; % total stimulus duration (frames)

% -> spatial size and location Gaussian envelope
ExpSettings.env_size_deg = 0.125;      % half-size of envelope (deg)
env_size_pix = round(ExpSettings.env_size_deg * ExpSettings.degTOpix); % half-size of envelope (pix)

% -> Size of support in pixels, make odd number
im_wdth = 5*env_size_pix+1;
im_hght = 5*env_size_pix+1;

% -> Initial parameters of gabors:

% -> Spatial constant of the exponential "hull"
gabor_sc = env_size_pix;

% -> Frequency of sine grating:
gabor_freq_cpd = 4;  % (cyc/deg)
gabor_freq_cpp = gabor_freq_cpd * pixTOdeg;  % (cyc/pix)
gabor_period = 1 / gabor_freq_cpp;      % (pix)
pixTOphadeg = 360 / gabor_period;

% -> Contrast of grating (Michelson contrast):
gabor_contrast = 0.4;

% -> contrast ramp
ExpSettings.ramp_fr = 3; %duration for the ramp (frames), must be odd number
ramp_msec = ExpSettings.ramp_fr.*frTOmsec;
ExpSettings.ramp_frIN = (ExpSettings.ramp_fr-1)/2;
ExpSettings.ramp_frOUT= (ExpSettings.ramp_fr-1)/2;
contVecRamp=flip(linspace(0,gabor_contrast,ExpSettings.ramp_fr+2));
ExpStim.contRamp=contVecRamp(2:end-1);

% -> Aspect ratio width vs. height:
gabor_aspectratio = 1.0;

% -> stimulus rows and columns
ExpSettings.stim_nb_rows = 25;

% -> distance between 2 rows (or 2 columns)
ExpSettings.stim_row_dist_deg = 0.625;
stim_row_dist_pix = round(ExpSettings.stim_row_dist_deg * ExpSettings.degTOpix);

% -> stimulus size
ExpSettings.stim_size_deg = ExpSettings.stim_row_dist_deg * (ExpSettings.stim_nb_rows + 1/2);
stim_size_pix = round(ExpSettings.stim_size_deg * ExpSettings.degTOpix);

% -> inner blank disk
ExpSettings.stim_inner_deg = 7 * ExpSettings.stim_row_dist_deg;
stim_inner_pix = round(ExpSettings.stim_inner_deg * ExpSettings.degTOpix);

% -> number of Gabors
ngabors = ExpSettings.stim_nb_rows * ExpSettings.stim_nb_rows;

% full stimulus dummy if one it will show the full
fullstim=0;


% -> Preallocate array with orientations (0 = vertical)
% ExpSettings.orient_deg_lst = (0:45:(180-45)) + 45/2;
ExpSettings.orient_deg_lst=1; % pick random
orient_nb = length(ExpSettings.orient_deg_lst);

% -> possible motion directions (0 = rightward motion; 90 = upward)
%ExpSettings.direction_deg_lst = (0:45:(360-45)) + 45/2;
ExpSettings.direction_deg_lst = 45:90:360;
%ExpSettings.direction_deg_lst=[157]
direction_nb = length(ExpSettings.direction_deg_lst);

% -> probability signal (prob. that a Gabor belongs to target)
% ExpSettings.prob_signal_lst = [0.4, 0.6, 0.8, 1.0];
%ExpSettings.prob_signal_lst = [0.3, 0.5, 0.7, 0.9];
ExpSettings.prob_signal_lst = [0.4, 0.7, 1];
%ExpSettings.prob_signal_lst = [1, 1 1];
if ExpSettings.print_instructions ==1
    ExpSettings.prob_signal_lst = [0.7 1];
end
prob_signal_nb = length(ExpSettings.prob_signal_lst);

% -> compute speed for each Gabor separately
ExpSettings.gabor_speed_deg_sec = 0.5;                          % (deg/sec)
gabor_speed_deg_fr = ExpSettings.gabor_speed_deg_sec / ExpSettings.fps;     % (deg/frame)
gabor_speed_pix_fr = gabor_speed_deg_fr * ExpSettings.degTOpix; % (pix/frame)
ExpSettings.gabor_speed_phadeg_fr = gabor_speed_pix_fr * pixTOphadeg;   % (phase_in_deg / frame)

% -> fixation point
ExpSettings.fix_duration_msec = 500;     % fixation duration (msec)

fix_xy = [0.0; 0.0];
ExpSettings.fix_size_deg = 8.0 / 60;    % 8 arcmin
fix_size_pix = ExpSettings.fix_size_deg * ExpSettings.degTOpix;

% Colors for fixation, add 0.5 to calculate their value
fix1_col = [0.5, 0.5, 0.5]; % 255 white if no mouse if present
fix2_col = [0.2, 0.2, 0.2]; % little darker gray
mouse_col = [0.3, 0.3, 0.3]; % little lighter gray

ExpSettings.mouse_size_deg = 12.0 / 60; % 12 arcmin
mouse_size_pix = ExpSettings.mouse_size_deg * ExpSettings.degTOpix;

% -> move mouse faster (when super-high monitor resolution)
ExpSettings.mouse_gain = 3.0;

% -> response ring
frame_default_thick_deg = 0.4;      % default ring width (deg)
%frame_chosen_thick_deg = 0.6;       % increase width when chosen (deg)
frame_chosen_thick_deg = 0.4;       % increase width when chosen (deg)
frame_default_thick_pix = frame_default_thick_deg * ExpSettings.degTOpix;   % (pix)
frame_chosen_thick_pix = frame_chosen_thick_deg * ExpSettings.degTOpix;     % (pix)
%frame_ang_eps = 5;        % small blank in-between ring sectors (deg)
frame_ang_eps = 22.5;        % small blank in-between ring sectors (deg)
%frame_startAngle_lst = 0:45:(360-45);
frame_startAngle_lst = 0:90:(360-45);
frame_startAngle_lst = frame_startAngle_lst + frame_ang_eps;
%frame_arcAngle = 45;
frame_arcAngle = 90;
frame_arcAngle = frame_arcAngle - 2 * frame_ang_eps;

% it extends in this diameters, it is not the centre point. Moreover, it is
% frame_default_thick_pix is not how big it is in diagonal. So, I should
% give litte more extra space, I should also cover the half of the gabor
frame_default_size_deg = ExpSettings.stim_size_deg + 3 * frame_default_thick_deg ;
frame_default_size_pix = round(frame_default_size_deg * ExpSettings.degTOpix)+ im_wdth;

% you just want to push this back little given by how big it ill get, there
% is two sides of the square so add total difference
frame_chosen_size_pix=frame_default_size_pix + (frame_chosen_thick_pix-frame_default_thick_pix);
ExpSettings.outerMost=frame_chosen_size_pix*pixTOdeg;

% extra degree
frame_resp_tol = 1*ExpSettings.degTOpix; % give a few more pixels around actual frame to respond
frame_radius_max = frame_default_size_pix/2 + frame_resp_tol;
frame_radius_min = frame_default_size_pix/2 - frame_default_thick_pix - frame_resp_tol;

% -> assign colors to ring segments that are easy to distinguish
ring_col_hsv_lst = NaN(direction_nb, 3);
hues1 = linspace(0, 1, direction_nb+1);
hues1 = hues1(1:direction_nb);

% -> reorder hues so that they are not contiguous
hues2 = NaN(1, direction_nb);
for ii = 1:direction_nb
    if mod(ii, 2)  % odd
        hues2(ii) = hues1(ii);
    else % even
        if (ii <= (direction_nb/2))
            hues2(ii) = hues1(ii+(direction_nb/2));
        else
            hues2(ii) = hues1(ii-(direction_nb/2));
        end
    end
end
ring_col_hsv_lst(:, 1) = hues2;
ring_col_hsv_lst(:, 2) = 0.333; % saturation
ring_col_hsv_lst(:, 3) = 0.750; % value
ring_col_rgb_lst = hsv2rgb(ring_col_hsv_lst);
ring_col_rgb_lst = ring_col_rgb_lst - 0.5;


% to indicate confidence choice change fixation color to red
FixationGoingRed{1}=[1 0.7 0.7];
FixationGoingRed{2}=[1 0.4 0.4];
FixationGoingRed{3}=[1 0.1 0.1];

ExpSettings.MouseChangin_FR = 3; % total change in mouse color (frames)
MouseChangin_sc=ExpSettings.MouseChangin_FR.*frTOmsec;

% threhsold for motor movement for response time in degrees
ExpSettings.motThreshold=0.5;

% ========================================================================
% -> independent variables


ExpSettings.xpNbRepeats = 12;
if ExpSettings.print_instructions ==1
    ExpSettings.xpNbRepeats = 4;
end
ExpSettings.xpNbConditions = 2;


ExpSettings.xpNbTrials = ExpSettings.xpNbRepeats * prob_signal_nb * prob_signal_nb;
xpLstTrials = NaN(ExpSettings.xpNbTrials, ExpSettings.xpNbConditions);

trialNumber = 0;

for c1 = 1:prob_signal_nb   % intrvl_1
    for c2 = 1:prob_signal_nb   % intrvl_2
        %         for c3 = 1:direction_nb
        %             for c4 = 1:direction_nb
        for rr = 1:ExpSettings.xpNbRepeats	% condition is identical for 'nbRepeats'
            trialNumber = trialNumber + 1;
            xpLstTrials(trialNumber, 1) = c1;
            xpLstTrials(trialNumber, 2) = c2;
            
            %                 end
            %             end
        end
    end
end


% shuffle the trials
xpLstTrials = xpLstTrials(randperm(ExpSettings.xpNbTrials), :);

% direction counter balance
if ExpSettings.print_instructions ==1
else
    orientationCounterBalancing=repmat(ExpSettings.direction_deg_lst,1,ExpSettings.xpNbTrials/(direction_nb*prob_signal_nb))';
    xpLstTrials(xpLstTrials(:,1)==1,3)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
    xpLstTrials(xpLstTrials(:,1)==2,3)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
    xpLstTrials(xpLstTrials(:,1)==3,3)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
  %  xpLstTrials(xpLstTrials(:,1)==4,3)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
    xpLstTrials(xpLstTrials(:,2)==1,4)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
    xpLstTrials(xpLstTrials(:,2)==2,4)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
    xpLstTrials(xpLstTrials(:,2)==3,4)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
   % xpLstTrials(xpLstTrials(:,2)==4,4)=orientationCounterBalancing(randperm(size(orientationCounterBalancing,1)), :);
end

%windmill start counter balance
if ExpSettings.print_instructions ==1
else
    windmlCounterBalancing=repmat([1 2],1,ExpSettings.xpNbTrials/(2*prob_signal_nb*prob_signal_nb))';
    for cohlvlT1=1:3
        for cohlvlT2=1:3
    xpLstTrials(and(xpLstTrials(:,1)==cohlvlT1,xpLstTrials(:,2)==cohlvlT2),5)=windmlCounterBalancing(randperm(size(windmlCounterBalancing,1)), :);
         end
    end
end

% ========================================================================
% -> I/O interface

KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
num1Key = KbName('1!');
num2Key = KbName('2@');
spaceKey = KbName('space');

fileDir = '/Users/martinszinte/Desktop/Data/';      % directory for data
fileName = sprintf('%s%s%s', fileDir, ExpSettings.subjectName, '.data');

% ========================================================================
ExpSettings.bckgColor = 0.5; % background luminance

Screen('Preference', 'SkipSyncTests', 1);   % skip sync tests...

% -> Setup defaults and unit color range:
AssertOpenGL;                           % Running on PTB-3?


if (~ExpSettings.screenWarnings)
    % -> suppresses the printout of warnings
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);
end

% -> Select screen with maximum id for output window:
screenid = max(Screen('Screens'));

% -> Open a fullscreen, onscreen window with gray background. Enable 32bpc
% floating point framebuffer via imaging pipeline on it, if this is possible
% on your hardware while alpha-blending is enabled. Otherwise use a 16bpc
% precision framebuffer together with alpha-blending.
PsychImaging('PrepareConfiguration');


PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
% Normalize the color in the range of 0-1.
PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
% Gamma correction
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');

[winPtr, winRect] = PsychImaging('OpenWindow', screenid, ExpSettings.bckgColor);
% Gamma correction
PsychColorCorrection('SetEncodingGamma', winPtr, 1/ExpSettings.gammaM );



% -> Enable alpha-blending, set it to a blend equation useable for linear
% additive superposition. This is why luminances are added to each other
% when you draw on top of each other.
Screen('BlendFunction', winPtr, GL_ONE, GL_ONE);

% -> enable alpha blending for smooth points
Screen('Preference', 'TextAlphaBlending', 1);
Screen('TextBackgroundColor', winPtr, [ExpSettings.bckgColor,ExpSettings.bckgColor,ExpSettings.bckgColor]);


% -> Retrieve size of window in pixels
[win_wdth, win_hght] = RectSize(winRect);
% coordinates of screen center (pixels)
winCenterXY = [win_wdth, win_hght]/2;

% if ((win_wdth ~= ExpSettings.resolDesired(1)) || (win_hght ~= ExpSettings.resolDesired(2)))
%     msg = sprintf('Warning: Screen resolution is %d x %d rather than %d x %d.', ...
%         win_wdth, win_hght, ExpSettings.resolDesired(1), ExpSettings.resolDesired(2));
%     Screen('TextSize', winPtr, 32);
%     Screen('DrawText', winPtr, msg, winCenterXY(1)-400, winCenterXY(2)-50, [ 1 1 1],[0 0 0]);
% end




% -> Query frame duration
ifi_tmp = Screen('GetFlipInterval', winPtr);
refreshRate = 1 / ifi_tmp;

if (abs(refreshRate - refreshRateDesired) < 2)
    refreshRate = refreshRateDesired;
else
    refreshRate = round(refreshRate);
    msg = sprintf('Warning: Refresh rate is %dHz rather than %dHz.', ...
        refreshRate, refreshRateDesired);
    Screen('TextSize', winPtr, 32);
    Screen('DrawText', winPtr, msg, winCenterXY(1)-200, winCenterXY(2), [ 1 1 1],[0 0 0]);
end


% fixation duration
fix_vbl = ExpSettings.fix_duration_msec/1000;

% -> somehow, the mouse seems to be using a different resolution
resol_struct = Screen('Resolution', winPtr);
mouse_center = winCenterXY;
%mouse_center = [resol_struct.width, resol_struct.height]/4;

% -> remove cursor
%HideCursor;
Screen('Flip', winPtr);
%ImageArrayLF=Screen('GetImage', winPtr);
WaitSecs(0.5);
if exist('msg','var')
    WaitSecs(4.5);
    ShowCursor;             % redisplay the cursor
    ListenChar(0);          % reenable transmission of keypresses to Matlab
    Screen('CloseAll');				% close the windows
    return
end

% ========================================================================

% -> Build a procedural gabor texture
% -> 'nonsymetric' flag set to 0 == Gabor has fixed aspect-ratio
% -> 'backgroundColorOffset', 'disableNorm', 'contrastPreMultiplicator'
% gabortex = CreateProceduralGabor(winPtr, im_wdth, im_hght, 0);
gabortex = CreateProceduralGabor(winPtr, im_wdth, im_hght, 0, [0,0,0,0], 1, 0.5);
% contrastPreMultiplicator interacts with michelson contrast, if it is 1 it
% doubles the intended contrast, the correct value is 0.5 (probably because
% it is contrast multiplicator).

% -> Draw the gabor once, just to make sure the gfx-hardware is ready for
% thebenchmark run below and doesn't do one time setup work inside the
% benchmark loop. The flag 'kPsychDontDoRotation' tells 'DrawTexture' not
% to apply its built-in texture rotation code for rotation, but just pass
% the rotation angle to the 'gabortex' shader -- it will implement its own
% rotation code, optimized for its purpose. Additional stimulus parameters
% like phase, sc, etc. are passed as 'auxParameters' vector to
% 'DrawTexture', this vector is just passed along to the shader. For
% technical reasons this vector must always contain a multiple of 4
% elements, so we pad with three zero elements at the end to get 8
% elements.
Screen('DrawTexture', winPtr, gabortex, [], [], [], [], [], [], [], ...
    kPsychDontDoRotation, [0, gabor_freq_cpp, gabor_sc, ...
    gabor_contrast, gabor_aspectratio, 0, 0, 0]);

% -> Preallocate array with destination rectangles:
% This also defines initial gabor patch orientations, scales and location
% for the very first drawn stimulus frame:
texrect = Screen('Rect', gabortex);

% windmill
anglesWINDstart=[-135:90:135];


ExpSettings.dstRects = NaN(4, ngabors);
ExpSettings.dstRects1 = NaN(4, ngabors);
ExpSettings.dstRects2 = NaN(4, ngabors);
gabor_count = 0;
for rr = 1:ExpSettings.stim_nb_rows
    for cc = 1:ExpSettings.stim_nb_rows
        gg = cc + ExpSettings.stim_nb_rows * (rr - 1);
        xpos = winCenterXY(1) + (rr - (ExpSettings.stim_nb_rows + 1)/2)*stim_row_dist_pix;
        ypos = winCenterXY(2) + (cc - (ExpSettings.stim_nb_rows + 1)/2)*stim_row_dist_pix;
        
        if (((xpos - winCenterXY(1))^2 + ...
                (ypos - winCenterXY(2))^2 <= (stim_size_pix/2)^2) && ...
                ((xpos - winCenterXY(1))^2 + ...
                (ypos - winCenterXY(2))^2 >= (stim_inner_pix/2)^2))
            % gabor_count = gabor_count + 1;
            ExpSettings.dstRects(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            
            
            % generate the windmill patterns
            anglPoint=atan2d((ypos - winCenterXY(2)),((xpos - winCenterXY(1))));
            if and(anglPoint>=anglesWINDstart(1),anglPoint<anglesWINDstart(1)+45)
                ExpSettings.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>anglesWINDstart(2),anglPoint<=anglesWINDstart(2)+45)
                ExpSettings.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>=anglesWINDstart(3),anglPoint<anglesWINDstart(3)+45)
                ExpSettings.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>anglesWINDstart(4),anglPoint<=anglesWINDstart(4)+45)
                ExpSettings.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            else
                ExpSettings.dstRects2(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
                gabor_count = gabor_count + 1;
            end
            
            
        end
        

        
    end
end

% -> prepare windmill
ExpSettings.dstRects = ExpSettings.dstRects(:, ~isnan(ExpSettings.dstRects(1, :))); % full stim
ExpSettings.dstRects1 = ExpSettings.dstRects1(:, ~isnan(ExpSettings.dstRects1(1, :))); % windmill 1
ExpSettings.dstRects2 = ExpSettings.dstRects2(:, ~isnan(ExpSettings.dstRects2(1, :))); % windmill 12
if fullstim==1
    gabor_count=gabor_count*2;
end


% -> Initialize matrix with spec for all 'ngabors' patches
%    (phase, frequency, sigma, contrast, aspect_ratio)
mypars = repmat([0, gabor_freq_cpp, gabor_sc, gabor_contrast, ...
    gabor_aspectratio, 0, 0, 0]', 1, gabor_count);

gabor_speed_inc = NaN(2, gabor_count);  % speed increments for the 2 intrvls
evidence_lst = NaN(direction_nb, gabor_count);
gabor_orient_deg = NaN(2, gabor_count);   % list of orientations for 2 intvls
gabor_phase_lst = NaN(2, gabor_count);  % phases for the 2 intrvls

% pre-allocation
is_signal = NaN(1, gabor_count);  %
intended_global_dir = NaN(1, gabor_count);
ExpStim.issignalS=NaN(ExpSettings.xpNbTrials,2,gabor_count);
ExpStim.intended_global_dirS=NaN(ExpSettings.xpNbTrials,2,gabor_count);
ExpStim.gabor_orient_degS=NaN(ExpSettings.xpNbTrials,2,gabor_count);
ExpStim.target_dir_lst_degS=NaN(ExpSettings.xpNbTrials,2);
ExpStim.prob_signal_intrvlS=NaN(ExpSettings.xpNbTrials,2);
ExpStim.gabor_speed_incS=NaN(ExpSettings.xpNbTrials,2,gabor_count);

resp_ring_rect = CenterRect([0 0 frame_default_size_pix frame_default_size_pix], winRect);
resp_ring_rect2 = CenterRect([0 0 frame_chosen_size_pix frame_chosen_size_pix], winRect);


% ========================================================================
% -> Open data file

fp = fopen(fileName, 'a');
currentTime = clock;
ye = currentTime(1); mo = currentTime(2); da = currentTime(3);
ho = currentTime(4); mi = currentTime(5); se = currentTime(6);

fprintf(fp, '\n*** Gabor Motion Confidence ***\n');
fprintf(fp, 'Subject Name:\t%s\n', ExpSettings.subjectName);
fprintf(fp, 'Date and Time:\t%2d/%2d/%4d\t%2d:%2d:%2.0f\n', da, mo, ye, ho, mi, se);
if isstruct(ExpSettings.seed)
    fprintf(fp, 'Seed = %.0f (generator=''%s'')\n', ExpSettings.seed.Seed, ExpSettings.whichGen);
else
    fprintf(fp, 'Seed = %.0f (generator=''%s'')\n', ExpSettings.seed, ExpSettings.whichGen);
end
fprintf(fp, 'Resolution=[%d, %d]  Refresh Rate=%2.1f\n', winRect(3), winRect(4), refreshRate);
fprintf(fp, 'Total Stimulus Duration = %7.2f ms\n', total_duration_msec);
fprintf(fp, 'Ramp of Stimulus = %7.2f ms\n', ramp_msec);
fprintf(fp, 'Gabor Contrast = %7.2f\n', gabor_contrast);
fprintf(fp, 'Gabor Speed = %7.2f deg/s\n', ExpSettings.gabor_speed_deg_sec);

fprintf(fp, '*** **************************** ***\n');
fprintf(fp, ' TrialNb\t Direction_1(deg)\t ProbSignal_1\t FracSignal_1\t');
fprintf(fp, ' FracEvid_1_1\t FracEvid_1_2\t FracEvid_1_3\t FracEvid_1_4\t');
fprintf(fp, ' FracEvid_1_5\t FracEvid_1_6\t FracEvid_1_7\t FracEvid_1_8\t');
fprintf(fp, ' Direction_2(deg)\t ProbSignal_2\t FracSignal_2\t');
fprintf(fp, ' FracEvid_2_1\t FracEvid_2_2\t FracEvid_2_3\t FracEvid_2_4\t');
fprintf(fp, ' FracEvid_2_5\t FracEvid_2_6\t FracEvid_2_7\t FracEvid_2_8\t');
fprintf(fp, ' ChoiceDirection_1\t ChoiceRT_1\t InterTrialDelay_1\t');
fprintf(fp, ' ChoiceDirection_2\t ChoiceRT_2\t InterTrialDelay_2\t');
fprintf(fp, ' ConfidenceIntrvl\t ConfRT\n');



% -> check the maximum priority level
priorityLevel = MaxPriority(winPtr);

% Continue data collection if there is previous session
if flagFORdataContinue==1
    load(strcat(ExpSettings.subjectName,'TMP.mat'))
    alreadydone=size(ExpRes.confResponse,2);
else
    alreadydone=0;
end

% -> tell participant this session is linked to previous data.
if flagFORdataContinue==1
    
    % make sure that participants do not see the single gabor drawn
    Screen('FillRect', winPtr, ExpSettings.bckgColor);
    Screen('TextSize',winPtr,32)
    Screen('DrawText',winPtr,'Your Previous Data is Found.',winCenterXY(1)-200,winCenterXY(2)-50,[ 1 1 1],[0 0 0]);
    Screen('DrawText',winPtr,'To Continue the Data Collection Press Spacebar',winCenterXY(1)-400,winCenterXY(2),[ 1 1 1],[0 0 0]);
    Screen('Flip', winPtr);
    %ImageArray=Screen('GetImage', winPtr);
    % -> check if subject wants to quit
    [keyIsDown, timeSecs, keyCode] = KbCheck;
    while 1
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        if keyCode(spaceKey)
            break;                 % exit
        end
        if keyCode(escapeKey)
            fclose(fp);				% close data file
            ShowCursor;             % redisplay the cursor
            ListenChar(0);          % reenable transmission of keypresses to Matlab
            Screen('CloseAll');				% close the windows
            return;                 % exit
        end
    end
end



% ========================================================================

for tt = 1+alreadydone:ExpSettings.xpNbTrials
    
    generationTime = tic;
    % -> global motion directions for the 2 intervals
    target_dir_lst_deg = NaN(1, 2);
    if ExpSettings.print_instructions ==1
        target_dir_lst_deg(1) = ExpSettings.direction_deg_lst(randi(direction_nb));
        target_dir_lst_deg(2) = ExpSettings.direction_deg_lst(randi(direction_nb));
        ExpStim.windMill(tt) = randi(2);
    else
        target_dir_lst_deg(1) = xpLstTrials(tt, 3);
        target_dir_lst_deg(2) = xpLstTrials(tt, 4);
        ExpStim.windMill(tt) = xpLstTrials(tt, 5);
    end
    
    ExpStim.target_dir_lst_degS(tt,:)=target_dir_lst_deg;
    
    
    % -> probability of signal in intervals 1 and 2
    prob_signal_intrvl = NaN(1, 2);
    whichProbSig1 = xpLstTrials(tt, 1);
    prob_signal_intrvl(1) = ExpSettings.prob_signal_lst(whichProbSig1);
    whichProbSig2 = xpLstTrials(tt, 2);
    prob_signal_intrvl(2) = ExpSettings.prob_signal_lst(whichProbSig2);
    
    ExpStim.prob_signal_intrvlS(tt,:)=prob_signal_intrvl;
    
    % -> print trial number in data file
    fprintf(fp, '%d\t', tt);
    
    
    % -> generate stimuli for the two intervals
    for intrvl = 1:2
        
        % -> randomize Gabor orientations (0 = vertical)
        if ExpSettings.orient_deg_lst ==1
            gabor_orient_deg(intrvl, :) = (randi([0, 4294967295],[1, gabor_count]) ./ 4294967296).*180;
            ExpStim.gabor_orient_degS(tt,intrvl,:)=gabor_orient_deg(intrvl, :);
        else
            gabor_orient_deg(intrvl, :) = ExpSettings.orient_deg_lst(randi(orient_nb, [1, gabor_count]));
            ExpStim.gabor_orient_degS(tt,intrvl,:)=gabor_orient_deg(intrvl, :);
        end
        
        % -> randomize Gabor phases
        gabor_phase_lst(intrvl, :) = (randi([0, 4294967295],[1, gabor_count]) ./ 4294967296).*360;
        
        % -> generate local speed value for each Gabor
        nb_signal = 0;
        for gg = 1:gabor_count
            gab_ori = gabor_orient_deg(intrvl, gg);
            
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
            vect_len = cos(angle_diff_deg * DTOR);  % vector length
            gabor_speed_inc(intrvl, gg) = ExpSettings.gabor_speed_phadeg_fr * vect_len;
            
            % -> compute target evidence for each potential global direction:
            %    evid = (gabor_speed / global_speed) * cos(gabor_direction, global_direction)
            for dd = 1:direction_nb
                tmp_dir_deg = ExpSettings.direction_deg_lst(dd);
                %                 signal_diff_deg = intended_global_dir - tmp_dir_deg;
                %                 evidence_lst(dd, gg) = abs(vect_len) * cos(signal_diff_deg * DTOR);
                signal_diff_deg = gab_ori - tmp_dir_deg;
                evidence_lst(dd, gg) = vect_len * cos(signal_diff_deg * DTOR);
            end
        end
        frac_signal = nb_signal / gabor_count;
        frac_evidence = sum(evidence_lst, 2) / gabor_count;
        
        % -> print independent variables in data file
        fprintf(fp, '%7.2f\t%6.3f\t', ...
            target_dir_lst_deg(intrvl), prob_signal_intrvl(intrvl));
        
        % -> print actual stimulus parameters in data file
        fprintf(fp, '%6.3f\t%6.3f\t', ...
            frac_signal, frac_evidence);
        %save the stim parameters
        ExpStim.issignalS(tt,intrvl,:)=is_signal;
        ExpStim.intended_global_dirS(tt,intrvl,:)=intended_global_dir;
        
    end     % 'intrvl'
    ExpStim.gabor_speed_incS(tt,:,:)=gabor_speed_inc;
    ExpRes.generationT(tt) = toc(generationTime);      % pair 2: toc
    % -> get accurate timing
    Priority(priorityLevel);
    
    
    
    if ExpSettings.print_instructions ==1
        if tt==1
            % make sure that participants do not see the single gabor drawn
            Screen('FillRect', winPtr, ExpSettings.bckgColor);
            Screen('TextSize',winPtr,32)
            Screen('DrawText',winPtr,'Press Spacebar to start training or hit ''ESC'' to stop.',winCenterXY(1)-500,winCenterXY(2),[ 1 1 1],[0 0 0]);
            Screen('Flip', winPtr);
            %ImageArray=Screen('GetImage', winPtr);
            % -> check if subject wants to quit
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            while 1
                [keyIsDown, timeSecs, keyCode] = KbCheck;
                if keyCode(spaceKey)
                    break;                 % exit
                end
                if keyCode(escapeKey)
                    fclose(fp);				% close data file
                    ShowCursor;             % redisplay the cursor
                    ListenChar(0);          % reenable transmission of keypresses to Matlab
                    Screen('CloseAll');				% close the windows
                    return;                 % exit
                end
            end
        end
        
    else
        
        % Blocks of the experiment / currently 4 blocks
        if mod(tt-1,(ExpSettings.xpNbTrials/4))==0
            
            
            % 10 seconds break
            if (tt-1)/(ExpSettings.xpNbTrials/4)~=0
                Screen('FillRect', winPtr, ExpSettings.bckgColor);
                Screen('TextSize',winPtr,32)
                msg = sprintf('Please take a break!');
                Screen('DrawText', winPtr, msg, winCenterXY(1)-150,winCenterXY(2) + 2,[ 1 1 1],[0 0 0]);
                Screen('Flip', winPtr);
                WaitSecs(2.0);
                for ii = 10:-1:1
                    msg = sprintf('%d', ii);
                    Screen('DrawText', winPtr, msg, winCenterXY(1) - 10, winCenterXY(2) + 2 ,[ 1 1 1],[0 0 0]);
                    Screen('Flip', winPtr);
                    WaitSecs(1.0);
                    Screen('FillRect', winPtr, ExpSettings.bckgColor);
                end
            end
            
            % ask for a key press for continuation
            Screen('FillRect', winPtr, ExpSettings.bckgColor);
            Screen('TextSize',winPtr,32)
            msg=sprintf('You have finished block #%d out of %d.', (tt-1)/(ExpSettings.xpNbTrials/4),4);
            Screen('DrawText',winPtr,msg,winCenterXY(1)-200,winCenterXY(2)-50,[ 1 1 1],[0 0 0]);
            Screen('DrawText',winPtr,'Press Spacebar to start block or hit ''ESC'' to stop.',winCenterXY(1)-500,winCenterXY(2),[ 1 1 1],[0 0 0]);
            Screen('Flip', winPtr);
            %ImageArray=Screen('GetImage', winPtr);
            % -> check if subject wants to quit
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            while 1
                [keyIsDown, timeSecs, keyCode] = KbCheck;
                if keyCode(spaceKey)
                    break;                 % exit
                end
                if keyCode(escapeKey)
                    fclose(fp);				% close data file
                    ShowCursor;             % redisplay the cursor
                    ListenChar(0);          % reenable transmission of keypresses to Matlab
                    Screen('CloseAll');				% close the windows
                    return;                 % exit
                end
            end
            
            
        end
        

    end
    
    
    
    
    
    % -> present the stimuli for the 2 intervals
    for intrvl = 1:2
        
        % -> fixation screen
        Screen('FillRect', winPtr, ExpSettings.bckgColor);
        Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix1_col, winCenterXY, 1);
        for rr = 1:direction_nb
            Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
                frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
        end
        vbl = Screen('Flip', winPtr);
        
        % -> random inter-trial interval
        
        waitFIX = 0.25 + rand * fix_vbl;
        ExpRes.IntervalBtwIntStart(intrvl,tt)=waitFIX;
        
        runClock = 1;
        keyIsDown2 = 0;
        t0f = GetSecs;
        while (runClock)
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            if (keyIsDown  && ~keyIsDown2)
                keyIsDown2 = keyIsDown;
                timeSecs2 = timeSecs;
                keyCode2 = keyCode;
            end
            if ((timeSecs - t0f) > waitFIX)
                runClock = 0;
            end
        end
 
        
        % -> call once KbCheck because the 1st call stalls matlab
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        
        
        % windmill
        if intrvl==1
            if ExpStim.windMill(tt)==1
                dtst=ExpSettings.dstRects1;
            else
                dtst=ExpSettings.dstRects2;
            end
        elseif intrvl==2
            if ExpStim.windMill(tt)==1
                dtst=ExpSettings.dstRects2;
            else
                dtst=ExpSettings.dstRects1;
            end
        end
        if fullstim==1
            dtst= ExpSettings.dstRects;
        end
            
        % -> collect Gabor orientations and phases for this interval
        gabor_orient = gabor_orient_deg(intrvl, :);
        mypars(1, :) = gabor_phase_lst(intrvl, :);
        gabor_speed = gabor_speed_inc(intrvl, :);
        ExpStim.myPars(:,:,tt,intrvl)=mypars;
        
        %moviePtr = Screen('CreateMovie', winPtr, 'movieFile.avi' );

        
        % -> *** DISPLAY STIMULUS ***
        for ff = 1:ExpSettings.total_duration_fr-(ExpSettings.ramp_frIN+1)
            
            % -> Batch-Draw all gabor patches at the positions and
            %    orientations and with the stimulus parameters 'mypars'
            Screen('DrawTextures', winPtr, gabortex, [], dtst, gabor_orient, ...
                [], [], [], [], kPsychDontDoRotation, mypars);
            
            % -> draw the fixation
            Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix1_col, winCenterXY, 1);
            
            for rr = 1:direction_nb
                Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
                    frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
            end
            
            % -> Mark drawing ops as finished, so the GPU can do its drawing job while
            %    we can compute updated parameters for next animation frame.
            Screen('DrawingFinished', winPtr);
            
            % -> Increment phase-shift of each gabor by 'inc' amount per redraw:
            mypars(1,:) = mypars(1,:) - gabor_speed;
            
            % -> Flip one video refresh after the last 'Flip'
            vbl = Screen('Flip', winPtr);
   
            if ff==1
                % -> start timer
                stLong = tic;
            end
            
        end

        
        for rampFr=1:ExpSettings.ramp_fr
            myparsFR=mypars;
            myparsFR(4,:)=ExpStim.contRamp(rampFr);
            
            
            % -> Batch-Draw all gabor patches at the positions and
            %    orientations and with the stimulus parameters 'mypars',kPsychDontDoRotation
            Screen('DrawTextures', winPtr, gabortex, [], dtst, gabor_orient, ...
                [], [], [], [], kPsychDontDoRotation, myparsFR);
            
            % -> draw the fixation
            Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix1_col, winCenterXY, 1);
            
            for rr = 1:direction_nb
                Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
                    frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
            end
            
            % -> Mark drawing ops as finished, so the GPU can do its drawing job while
            %    we can compute updated parameters for next animation frame.
            Screen('DrawingFinished', winPtr);
            Screen('Flip', winPtr);
            if rampFr==1
                ExpRes.stLongwR(intrvl,tt) = toc(stLong);      % pair 2: toc
                RampS = tic;
            elseif rampFr==(ExpSettings.ramp_frIN+1)+1 % when the third frame flipped, we are officially out of 500 ms region
                ExpRes.stLong(intrvl,tt) = toc(stLong);      % pair 2: toc
            end
            
        end
        
   

        % only response ring
        
        for rr = 1:direction_nb
            Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
                frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
        end
        Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix2_col, winCenterXY, 1);
        vbl = Screen('Flip', winPtr);
        ExpRes.RampS(intrvl,tt) = toc(RampS);      % pair 2: toc
        %ImageArrayLF=Screen('GetImage', winPtr);
        % start the response time
        t0 = GetSecs;
        % -> *****************************************************************
        % -> Get first answer <-
        % -> *****************************************************************
        
        % -> Move the cursor to the center of the screen
        SetMouse(mouse_center(1), mouse_center(2), winPtr);
        %HideCursor;             % remove cursor (sometimes it re-appears)
        
        WaitSecs(1)
        
%         % -> Loop and track the mouse
%         choiceMade = 0;
%         doneMOT=0;
%         tstart = GetSecs;
%         while (~choiceMade)
%             [theX, theY, buttons] = GetMouse(winPtr);
%             mouse_xy = [theX, theY] - mouse_center;
%             
%             mouse_xy = mouse_xy .* ExpSettings.mouse_gain;
%             
%             % you cant leave the screen
%             cordins = [theX, theY] - mouse_center;
%             if and(abs(cordins(1))>((win_wdth-mouse_center(1))/ExpSettings.mouse_gain),abs(cordins(2))>((win_hght-mouse_center(2))/ExpSettings.mouse_gain))
%                 SetMouse((win_wdth/2)+ sign(cordins(1))*((win_wdth-mouse_center(1))/ExpSettings.mouse_gain-3) , (win_hght/2)+ sign(cordins(2))*((win_hght-mouse_center(2))/ExpSettings.mouse_gain-3), winPtr);
%             elseif abs(cordins(1))>((win_wdth-mouse_center(1))/ExpSettings.mouse_gain)
%                 SetMouse((win_wdth/2)+ sign(cordins(1))*((win_wdth-mouse_center(1))/ExpSettings.mouse_gain-3) , theY, winPtr);
%                 
%             elseif abs(cordins(2))>((win_hght-mouse_center(2))/ExpSettings.mouse_gain)
%                 SetMouse(theX,(win_hght/2)+ sign(cordins(2))*((win_hght-mouse_center(2))/ExpSettings.mouse_gain-3),  winPtr);
%             end
%             
%             % radius for mouse
%             mouse_radius = hypot(mouse_xy(1), mouse_xy(2));
%             
%             % reaction time collection without the motor part
%             % assuming that 0.1 degree is voluntary and decision
%             % indictive,
%             
%             if ((mouse_radius > ExpSettings.motThreshold*ExpSettings.degTOpix))  && (doneMOT==0)
%                 t11 = GetSecs;
%                 mouseRespTimeMOTOR = t11 - t0;
%                 ExpRes.RespTimeMOTOR(intrvl,tt)=mouseRespTimeMOTOR;
%                 doneMOT=1;
%             end
%             
%             
%             % -> locate which quandrant the subject is interested in
%             if ((mouse_radius < frame_radius_max) && (mouse_radius > frame_radius_min))
%                 
%                 % -> the mouse is hovering over one sector
%                 mouse_angle_rad = atan2(mouse_xy(2), mouse_xy(1));
%                 mouse_angle_deg = mouse_angle_rad * RTOD;
%                 mouse_angle_deg = 360 - mod(mouse_angle_deg, 360); % convert (0, 360)
%                 
%                 [~, direction_ind] = min(abs(mouse_angle_deg - ExpSettings.direction_deg_lst));
%                 %frame_ind = mod((10 - direction_ind), 8) + 1;
%                 frame_ind = mod((5 - direction_ind), 4)+1 ;
%                 
%                 ring_col_hsv_lst2 = ring_col_hsv_lst;
%                 ring_thick = frame_chosen_thick_pix;
%                 resp_rect = resp_ring_rect2;
%                 
%                 % -> check whether there is a sector selected
%                 if (buttons(1))
%                     choiceMade = 1;
%                     t1 = GetSecs;
%                     
%                     % -> feedback about which sector was selected
% %                     ring_col_hsv_lst2(:, 3) = 0.4; % change value of sectors other than choice
% %                     ring_col_hsv_lst2(frame_ind, 3) = 1.0; % change value of choice
%                 else
% %                     ring_col_hsv_lst2(:, 3) = 0.6; % change value of sectors other than choice
% %                     ring_col_hsv_lst2(frame_ind, 3) = 0.85; % change value of choice
%                 end
% %                 ring_col_rgb_lst2 = hsv2rgb(ring_col_hsv_lst2) - 0.5;
%                 
%             else
%                 ring_col_rgb_lst2 = ring_col_rgb_lst;
%                 ring_thick = frame_default_thick_pix;
%                 resp_rect = resp_ring_rect;
%             end
%             
%             % -> redraw sectors and fixation
%             for rr = 1:direction_nb
%                 Screen('FrameArc', winPtr, ring_col_rgb_lst2(rr, :), resp_rect, ...
%                     frame_startAngle_lst(rr), frame_arcAngle, ring_thick, ring_thick);
%             end
%             Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix2_col, winCenterXY, 1);
%             Screen('DrawDots', winPtr, mouse_xy, mouse_size_pix, mouse_col, winCenterXY, 1);
%             vbl = Screen('Flip', winPtr);
%             
%             if vbl-tstart > 1000
%                 choiceMade = 1;
%             end
%             
%             %ImageArrayLF=Screen('GetImage', winPtr);
%             
%             % -> check if subject wants to quit
%             [keyIsDown, timeSecs, keyCode] = KbCheck;
%             if (keyIsDown)
%                 %             respChar = KbName(keyCode);
%                 if keyCode(escapeKey)
%                     fclose(fp);				% close data file
%                     ShowCursor;             % redisplay the cursor
%                     ListenChar(0);          % reenable transmission of keypresses to Matlab
%                     Screen('CloseAll');				% close the windows
%                     return;                 % exit
%                 end
%             end
%             
%         end
%         
%         
%         
%         mouseRespTime = t1 - t0;
        ExpRes.RespTime(intrvl,tt)=1000;
        ExpRes.RespDirection(intrvl,tt)=ExpSettings.direction_deg_lst(1);
        fprintf(fp, '%7.2f\t%7.3f\t', ExpSettings.direction_deg_lst(1), 1);
%         
        % -> relax, return to normal priority level
        Priority(0);
        
        % -> call KbCheck to empty buffer
        %     [keyIsDown, timeSecs, keyCode] = KbCheck;
        while KbCheck; end
        
        % ImageArrayLF=Screen('GetImage', winPtr);
        
        % -> small pause to actually see the feedback of sector chosen
        %     WaitSecs(0.2);
        wait = 0.2;
        runClock = 1;
        keyIsDown1 = 0;
        t0 = GetSecs;
        while (runClock)
            [keyIsDown, timeSecs, keyCode] = KbCheck;
            if (keyIsDown  && ~keyIsDown1)
                keyIsDown1 = keyIsDown;
                timeSecs1 = timeSecs;
                keyCode1 = keyCode;
            end
            if ((timeSecs - t0) > wait)
                runClock = 0;
            end
        end
        
        
        % give the feedback tone if it is training
        if ExpSettings.print_instructions ==1
            if ExpRes.RespDirection(intrvl,tt)== ExpStim.target_dir_lst_degS(tt,intrvl)
                freqs = 1200;
                duration = 0.2;
                sampleFreq = 44100;
                dt = 1/sampleFreq;
                ttr = [0:dt:duration];
                s=sin(2*pi*freqs(1)*ttr)*0.7;
                sound(s,sampleFreq);
            else
                freqs = 400;
                duration = 0.2;
                sampleFreq = 44100;
                dt = 1/sampleFreq;
                ttr = [0:dt:duration];
                s=sin(2*pi*freqs(1)*ttr)*0.7;
                sound(s,sampleFreq);
            end
        end
        
    end
    % -> fixation screen
    Screen('FillRect', winPtr, ExpSettings.bckgColor);
    Screen('DrawDots', winPtr, fix_xy, fix_size_pix, fix1_col, winCenterXY, 1);
    for rr = 1:direction_nb
        Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
            frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
    end
    
    vbl = Screen('Flip', winPtr);
        
        
        
    % -> random inter-trial interval
    wait = 0.50 - MouseChangin_sc/1000;
        
    fprintf(fp, '%7.2f\t', wait);
    ExpRes.IntervalBtwTrials(tt)=wait;
    %     WaitSecs(wait);
    runClock = 1;
    keyIsDown2 = 0;
    t0 = GetSecs;
    while (runClock)
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        if (keyIsDown  && ~keyIsDown2)
            keyIsDown2 = keyIsDown;
            timeSecs2 = timeSecs;
            keyCode2 = keyCode;
        end
        if ((timeSecs - t0) > wait)
            runClock = 0;
        end
    end
    
    
    
    
    %     'intrvl'
    
    % -> fixation screen changin
    for slowB=1:ExpSettings.MouseChangin_FR
        Screen('FillRect', winPtr, ExpSettings.bckgColor);
        Screen('DrawDots', winPtr, fix_xy, fix_size_pix, FixationGoingRed{slowB}, winCenterXY, 1);
        if slowB==ExpSettings.MouseChangin_FR
            msg1 = '1st ';
            msg2 = '2nd ';
            Screen('TextSize', winPtr, 32);
            Screen('DrawText', winPtr, msg1, winCenterXY(1)-200, winCenterXY(2)-15, [ 1 1 1],[0 0 0]);
            Screen('TextSize', winPtr, 32);
            Screen('DrawText', winPtr, msg2, winCenterXY(1)+200, winCenterXY(2)-15, [ 1 1 1],[0 0 0]);
        end
        for rr = 1:direction_nb
            Screen('FrameArc', winPtr, ring_col_rgb_lst(rr, :), resp_ring_rect, ...
                frame_startAngle_lst(rr), frame_arcAngle, frame_default_thick_pix, frame_default_thick_pix);
        end
        
        vbl = Screen('Flip', winPtr);
    end
    
    %  ImageArrayLF=Screen('GetImage', winPtr);
    
    % -> restart timer for confidence judgment (if intrvl = 2)
    t0 = GetSecs;
    % -> now collect confidence forced-choice
    responseProcessed = 0;
    keyIsDown=0;
    % -> Get the answer
    while (~responseProcessed)
        
        [keyIsDown, timeSecs, keyCode] = KbCheck;
        
        if (keyIsDown && ~responseProcessed)
            %             respChar = KbName(keyCode);
            respTime = timeSecs - t0;
            if keyCode(escapeKey)
                fclose(fp);				% close data file
                ShowCursor;             % redisplay the cursor
                ListenChar(0);          % reenable transmission of keypresses to Matlab
                Screen('CloseAll');				% close the windows
                return;                 % exit
            elseif (keyCode(leftKey) || keyCode(rightKey))
                if (keyCode(leftKey))
                    %                     respLett = 'L';
                    conf_resp = 1;
                else
                    %                     respLett = 'R';
                    conf_resp = 2;
                end
                %                 fprintf(fp, '%c\t%7.2f\t', respLett, respTime*1000);
                fprintf(fp, '%d\t%7.2f\t', conf_resp, respTime);
                ExpRes.confResponse(tt)=conf_resp;
                ExpRes.confRespTime(tt)=respTime;
                responseProcessed = 1;
            end
        end
    end
    
    
    % give the feedback tone if it is training
    if ExpSettings.print_instructions ==1
        % normally I expect cohdiff to be determinant, bu it has to be
        % correct with whether the response is correct
        crc1=ExpRes.RespDirection(1,tt)== ExpStim.target_dir_lst_degS(tt,1);
        crc2=ExpRes.RespDirection(2,tt)== ExpStim.target_dir_lst_degS(tt,2);
        cohdiff=ExpStim.prob_signal_intrvlS(tt,1)-ExpStim.prob_signal_intrvlS(tt,2);
        if crc1==0 && crc2==1
            if cohdiff>=0
                cohdiff=cohdiff+-2;
            end
        elseif crc1==1 && crc2==0
            if cohdiff<=0
                cohdiff=cohdiff+2;
            end
        end
        if (ExpRes.confResponse(tt)== 2) && (cohdiff<0)
            freqs = 1200; % 1200
            duration = 0.2;
            sampleFreq = 44100;
            dt = 1/sampleFreq;
            ttr = [0:dt:duration];
            s=sin(2*pi*freqs(1)*ttr)*0.7;
            sound(s,sampleFreq);
            
        elseif (ExpRes.confResponse(tt)== 1) && (cohdiff>0)
            freqs = 1200; % 1200
            duration = 0.2;
            sampleFreq = 44100;
            dt = 1/sampleFreq;
            ttr = [0:dt:duration];
            s=sin(2*pi*freqs(1)*ttr)*0.7;
            sound(s,sampleFreq);
        elseif cohdiff==0
            freqs = 1200; % 1200
            duration = 0.2;
            sampleFreq = 44100;
            dt = 1/sampleFreq;
            ttr = [0:dt:duration];
            s=sin(2*pi*freqs(1)*ttr)*0.7;
            sound(s,sampleFreq);
        else
            freqs = 400; % 1200
            duration = 0.2;
            sampleFreq = 44100;
            dt = 1/sampleFreq;
            ttr = [0:dt:duration];
            s=sin(2*pi*freqs(1)*ttr)*0.7;
            sound(s,sampleFreq);
            
        end
    end
    
    
    fprintf(fp, '\n');
    save(strcat(ExpSettings.subjectName,'TMP.mat'),'ExpSettings','ExpStim','ExpRes')
end

% ========================================================================
% end screen
Screen('FillRect', winPtr, ExpSettings.bckgColor);
msg = sprintf('You have finished!  Thank you!');
Screen('DrawText', winPtr, msg, winCenterXY(1)-300,  winCenterXY(2) - 30,[ 1 1 1],[0 0 0]);
Screen('Flip', winPtr);
WaitSecs(4.0);

% Clean up everything and leave
ShowCursor;						% redisplay the cursor
ListenChar(0);                  % reenable transmission of keypresses to Matlab
Screen('CloseAll');				% close the on- and off-Screen windows
if (~ExpSettings.screenWarnings)
    Screen('Preference','SuppressAllWarnings',oldEnableFlag); % restore the old level
end
save(strcat(ExpSettings.subjectName,'.mat'),'ExpSettings','ExpStim','ExpRes')
% delete temporary save
tempFile=strcat(ExpSettings.subjectName,'TMP.mat');
delete(tempFile)

% ========================================================================
% -> THE END <-
% ========================================================================

