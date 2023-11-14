function const = constConfig(scr, const)
% ----------------------------------------------------------------------
% const = constConfig(scr, const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define all constant configurations
% ----------------------------------------------------------------------
% Input(s) :
% scr : struct containing screen configurations
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

% Randomization
[const.seed, const.whichGen] = ClockRandSeed;

% Colors
const.white = [1, 1, 1];
const.black = [0,0,0];
const.gray = [0.5, 0.5, 0.5];
const.red = [0.8, 0, 0];
const.green = [0, 0.8, 0];
const.background_color = const.gray; 

% Time parameters
const.TR_sec = 1.2;                                                         % MRI time repetition in seconds
const.TR_frm = round(const.TR_sec/scr.frame_duration);                      % MRI time repetition in seconds in screen frames

const.mot_dur_sec = 1 * const.TR_sec;                                       % Motion stimulus duration in seconds
const.mot_dur_frm = round(const.mot_dur_sec /scr.frame_duration);           % Total stimulus duration in screen frames

const.mot_resp_dur_sec = 2 * const.TR_sec;                                  % Motion response time duration in seconds
const.mot_resp_dur_frm = round(const.mot_resp_dur_sec/scr.frame_duration);  % Motion response time duration in screen frames

const.iti_dur_sec = 1 * const.TR_sec;                                       % Inter-trial interval duration in seconds
const.iti_dur_frm = round(const.iti_dur_sec/scr.frame_duration);            % Inter-trial interval duration in screen frames

const.conf_resp_dur_sec = 2 * const.TR_sec;                                 % Confidence response duration in seconds
const.conf_resp_dur_frm = round(const.conf_resp_dur_sec/...
    scr.frame_duration);                                                    % Confidence response duration in screen frames

const.ramp_fr = 3;                                                          % Duration of the ramp (must be odd number) in screen frames
const.ramp_sec = const.ramp_fr*scr.frame_duration;                          % Duration of the ramp in seconds

% Stim parameters
[const.ppd] = vaDeg2pix(1, scr); % one pixel per dva
const.dpp = 1/const.ppd;    
const.env_size_dva = 0.125;                                                 % Half-size of envelope (dva)
const.env_size_pix = vaDeg2pix(const.env_size_dva, scr);                    % half-size of envelope (pix)

const.im_wdth = 5*const.env_size_pix+1;                                     % Size of support in pixels, make odd number (?)
const.im_hght = 5*const.env_size_pix+1;                                     % Size of support in pixels, make odd number (?)

const.gabor_sc = const.env_size_pix;                                        % Spatial constant of the exponential "hull"
const.gabor_freq_cpd = 4;                                                   % Frequency of sine grating in cycle/dva
const.gabor_freq_cpp = const.gabor_freq_cpd * const.dpp;                    % Frequency of sine grating in cycle/pix
const.gabor_period = 1 / const.gabor_freq_cpp;                              % Period of sine grating in pix
const.pix2phadva = 360 / const.gabor_period;                                % (?)
const.gabor_contrast = 0.4;                                                 % Contrast of grating (Michelson contrast)
const.gabor_aspectratio = 1.0;                                              % Gabor aspect ratio width vs. height:

const.ramp_frIN = (const.ramp_fr-1)/2;                                      % (?)
const.ramp_frOUT = (const.ramp_fr-1)/2;                                     % (?)
const.contVecRamp = flip(linspace(0,const.gabor_contrast,const.ramp_fr+2)); % (?)
const.contRamp = const.contVecRamp(2:end-1);                                % (?)

const.stim_nb_rows = 25;                                                    % Stimulus rows and columns
const.stim_row_dist_dva = 0.625;                                            % Distance between 2 rows (or 2 columns) in dva
const.stim_row_dist_pix = vaDeg2pix(const.stim_row_dist_dva, scr);          % Distance between 2 rows (or 2 columns) in pix

const.stim_size_dva = const.stim_row_dist_dva * (const.stim_nb_rows + 1/2); % Stimulus size in dva
const.stim_size_pix = vaDeg2pix(const.stim_size_dva, scr);                  % Stimulus size in pix

const.stim_inner_dva = 7 * const.stim_row_dist_dva;                         % Inner blank disk in dva
const.stim_inner_pix = vaDeg2pix(const.stim_inner_dva, scr);                % Inner blank disk in pix

const.ngabors = const.stim_nb_rows * const.stim_nb_rows;

const.orient_dva_lst = 1;                                                   % orientation (?)
const.orient_nb = length(const.orient_dva_lst);                             % number of orientations

const.direction_dva_lst = 45:90:360;                                        % list of possible motion directions (0 = rightward motion; 90 = upward)
const.direction_dva_txt = {'45 deg', '135 deg', '225 deg', '315 deg'};      % list of signal probabiliyt in text
const.direction_nb = length(const.direction_dva_lst);                       % number of possible motion directions

const.prob_signal_lst = [0.4, 0.7, 1];                                      % list of signal probability (prob. that a Gabor belongs to target)
const.prob_signal_txt = {'0.4', '0.7', '1'};                                % list of signal probabiliyt in text
const.prob_signal_nb = length(const.prob_signal_lst);                       % number of signal probability

const.gabor_speed_dva_sec = 0.5;                                            % Gabor speed in dva/sec
const.gabor_speed_dva_frm = const.gabor_speed_dva_sec / scr.hz;             % Gabor speed in dva/frame
const.gabor_speed_pix_frm = const.gabor_speed_dva_frm * const.ppd;          % Gabor speed in pix/frame
const.gabor_speed_phadeg_frm = const.gabor_speed_pix_frm * const.pix2phadva;% Gabor speed in phase in dva/frame

const.frame_default_thick_dva = 0.4;                                        % (?) default ring width (deg)
const.frame_chosen_thick_dva = 0.4;                                         % (?) increase width when chosen (deg)
const.frame_default_thick_pix = vaDeg2pix(const.frame_default_thick_dva,...
    scr);                                                                   % (?)
const.frame_chosen_thick_pix = vaDeg2pix(const.frame_default_thick_dva,...
    scr);                                                                   % (?)

const.frame_ang_eps = 22.5;                                                 % (?) small blank in-between ring sectors (deg)
const.frame_startAngle_lst = 0:90:(360-45);                                 % (?)
const.frame_startAngle_lst = const.frame_startAngle_lst + const.frame_ang_eps; % (?)

const.frame_arcAngle = 90;                                                  % (?)
const.frame_arcAngle = const.frame_arcAngle - 2 * const.frame_ang_eps;      % (?)

% it extends in this diameters, it is not the centre point. Moreover, it is
% frame_default_thick_pix is not how big it is in diagonal. So, I should
% give litte more extra space, I should also cover the half of the gabor
const.frame_default_size_dva = const.stim_size_dva + 3 * const.frame_default_thick_dva;         % (?)
const.frame_default_size_pix = vaDeg2pix(const.frame_default_size_dva, scr) + const.im_wdth;    % (?)

% you just want to push this back little given by how big it ill get, there
% is two sides of the square so add total difference
const.frame_chosen_size_pix = const.frame_default_size_pix +...
    (const.frame_chosen_thick_pix-const.frame_default_thick_pix);
const.outerMost = const.frame_chosen_size_pix * const.ppd;

% extra degree
const.frame_resp_tol = vaDeg2pix(1, scr);                                   % give a few more pixels around actual frame to respond
const.frame_radius_max = const.frame_default_size_pix/2 ...
    + const.frame_resp_tol;                                                 % (?)
const.frame_radius_min = const.frame_default_size_pix/2 ...
    - const.frame_default_thick_pix - const.frame_resp_tol;                 % (?)

const.ring_col_hsv_lst = NaN(const.direction_nb, 3);
const.hues1 = linspace(0, 1, const.direction_nb+1);
const.hues1 = const.hues1(1:const.direction_nb);

const.hues2 = NaN(1, const.direction_nb);
const.hues2 = NaN(1, const.direction_nb);
for ii = 1:const.direction_nb
    if mod(ii, 2)  % odd
        const.hues2(ii) = const.hues1(ii);
    else % even
        if (ii <= (const.direction_nb/2))
            const.hues2(ii) = const.hues1(ii+(const.direction_nb/2));
        else
            const.hues2(ii) = const.hues1(ii-(const.direction_nb/2));
        end
    end
end
const.ring_col_hsv_lst(:, 1) = const.hues2;
const.ring_col_hsv_lst(:, 2) = 0.333; % saturation
const.ring_col_hsv_lst(:, 3) = 0.750; % value
const.ring_col_rgb_lst = hsv2rgb(const.ring_col_hsv_lst);
const.ring_col_rgb_lst = const.ring_col_rgb_lst-0.5;
const.ring_col_rgb_lst = const.ring_col_rgb_lst;

const.color_wheel_rect = CenterRect([0, 0, const.frame_chosen_size_pix, ...
                                    const.frame_chosen_size_pix], ...
                                    [0, 0, scr.scr_sizeX, scr.scr_sizeY]);

% Trial settings
const.nb_repeat = 4;
const.nb_trials = const.nb_repeat * length(const.prob_signal_lst) * ...
    length(const.prob_signal_lst);

% Compute a single gabor
texrect = [0, 0, const.im_wdth, const.im_hght];

% windmill
anglesWINDstart=[-135:90:135];
                                
const.dstRects = NaN(4, const.ngabors);
const.dstRects1 = NaN(4, const.ngabors);
const.dstRects2 = NaN(4, const.ngabors);
const.gabor_count = 0;
for rr = 1:const.stim_nb_rows
    for cc = 1:const.stim_nb_rows
        gg = cc + const.stim_nb_rows * (rr - 1);
        xpos = scr.x_mid + (rr - (const.stim_nb_rows + 1)/2)*const.stim_row_dist_pix;
        ypos = scr.y_mid + (cc - (const.stim_nb_rows + 1)/2)*const.stim_row_dist_pix;
        
        if (((xpos - scr.x_mid)^2 + ...
                (ypos - scr.y_mid)^2 <= (const.stim_size_pix/2)^2) && ...
                ((xpos - scr.x_mid)^2 + ...
                (ypos - scr.y_mid)^2 >= (const.stim_inner_pix/2)^2))
            
            const.dstRects(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
               
            % generate the windmill patterns
            anglPoint = atan2d((ypos - scr.y_mid), ((xpos - scr.x_mid)));
            if and(anglPoint>=anglesWINDstart(1),anglPoint<anglesWINDstart(1)+45)
                const.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>anglesWINDstart(2),anglPoint<=anglesWINDstart(2)+45)
                const.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>=anglesWINDstart(3),anglPoint<anglesWINDstart(3)+45)
                const.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            elseif  and(anglPoint>anglesWINDstart(4),anglPoint<=anglesWINDstart(4)+45)
                const.dstRects1(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
            else
                const.dstRects2(:, gg) = CenterRectOnPoint(texrect, xpos, ypos)';
                const.gabor_count = const.gabor_count + 1;
            end
        end
    end
end

% -> prepare windmill
const.dstRects1 = const.dstRects1(:, ~isnan(const.dstRects1(1, :))); % windmill 1
const.dstRects2 = const.dstRects2(:, ~isnan(const.dstRects2(1, :))); % windmill 12

if size(const.dstRects2,2)==size(const.dstRects1,2)
else
    error('Windmill conditions should have equal numbers of Gabors, try to use different ppd')   
end


const.mypars = repmat([0, const.gabor_freq_cpp, const.gabor_sc, ...
    const.gabor_contrast, const.gabor_aspectratio, 0, 0, 0]', 1, ...
    const.gabor_count);

const.gabor_speed_inc = NaN(2, const.gabor_count);                  % speed increments for the 2 intrvls
const.evidence_lst = NaN(const.direction_nb, const.gabor_count);
const.gabor_orient_deg = NaN(2, const.gabor_count);                 % list of orientations for 2 intvls
const.gabor_phase_lst = NaN(2, const.gabor_count);                  % phases for the 2 intrvls

% pre-allocation
const.is_signal = NaN(1, const.gabor_count);
const.intended_global_dir = NaN(1, const.gabor_count);
const.issignalS = NaN(const.nb_trials, 2, const.gabor_count);
const.intended_global_dirS = NaN(const.nb_trials, 2, const.gabor_count);
const.gabor_orient_degS = NaN(const.nb_trials, 2, const.gabor_count);
const.target_dir_lst_degS = NaN(const.nb_trials, 2);
const.prob_signal_intrvlS = NaN(const.nb_trials, 2);
const.gabor_speed_incS = NaN(const.nb_trials, 2, const.gabor_count);



% define total TR numbers and scan duration
if const.scanner
    const.TRs = 0;
    fprintf(1,'\n\tScanner parameters; %1.0f TRs, %1.2f seconds, %s\n',...
        const.TRs,const.TR_dur,datestr(seconds((const.TRs*const.TR_dur)),'MM:SS'));
end

% Eyelink calibration value
const.fix_out_rim_radVal = 0.25;                                            % radius of outer circle of fixation bull's eye in dva
const.fix_rim_radVal = 0.75*const.fix_out_rim_radVal;                       % radius of intermediate circle of fixation bull's eye in dva
const.fix_radVal = 0.25*const.fix_out_rim_radVal;                           % radius of inner circle of fixation bull's eye in dva
const.fix_out_rim_rad = vaDeg2pix(const.fix_out_rim_radVal, scr);           % radius of outer circle of fixation bull's eye in pixels
const.fix_rim_rad = vaDeg2pix(const.fix_rim_radVal, scr);                   % radius of intermediate circle of fixation bull's eye in pixels
const.fix_rad = vaDeg2pix(const.fix_radVal, scr);                           % radius of inner circle of fixation bull's eye in pixels

% Personal calibrations
angle = 0:pi/3:5/3*pi;
 
% compute calibration target locations
const.calib_amp_ratio  = 0.5;
[cx1,cy1] = pol2cart(angle,const.calib_amp_ratio);
[cx2,cy2] = pol2cart(angle+(pi/6),const.calib_amp_ratio*0.5);
cx = round(scr.x_mid + scr.x_mid*[0 cx1 cx2]);
cy = round(scr.y_mid + scr.x_mid*[0 cy1 cy2]);
 
% order for eyelink
const.calibCoord = round([  cx(1), cy(1),...   % 1.  center center
                            cx(9), cy(9),...   % 2.  center up
                            cx(13),cy(13),...  % 3.  center down
                            cx(5), cy(5),...   % 4.  left center
                            cx(2), cy(2),...   % 5.  right center
                            cx(4), cy(4),...   % 6.  left up
                            cx(3), cy(3),...   % 7.  right up
                            cx(6), cy(6),...   % 8.  left down
                            cx(7), cy(7),...   % 9.  right down
                            cx(10),cy(10),...  % 10. left up
                            cx(8), cy(8),...   % 11. right up
                            cx(11),cy(11),...  % 12. left down
                            cx(12),cy(12)]);    % 13. right down

% compute validation target locations (calibration targets smaller radius)
const.valid_amp_ratio = const.calib_amp_ratio*0.8;
[vx1,vy1] = pol2cart(angle,const.valid_amp_ratio);
[vx2,vy2] = pol2cart(angle+pi/6,const.valid_amp_ratio*0.5);
vx = round(scr.x_mid + scr.x_mid*[0 vx1 vx2]);
vy = round(scr.y_mid + scr.x_mid*[0 vy1 vy2]);
 
% order for eyelink
const.validCoord =round( [  vx(1), vy(1),...   % 1.  center center
                             vx(9), vy(9),...   % 2.  center up
                             vx(13),vy(13),...  % 3.  center down
                             vx(5), vy(5),...   % 4.  left center
                             vx(2), vy(2),...   % 5.  right center
                             vx(4), vy(4),...   % 6.  left up
                             vx(3), vy(3),...   % 7.  right up
                             vx(6), vy(6),...   % 8.  left down
                             vx(7), vy(7),...   % 9.  right down
                             vx(10),vy(10),...  % 10. left up
                             vx(8), vy(8),...   % 11. right up
                             vx(11),vy(11),...  % 12. left down
                             vx(12),vy(12)]);    % 13. right down

end