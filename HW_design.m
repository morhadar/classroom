%% approximation for division in a number which is not a result of power of 2:
% for example:
% divide in 81: 81 =~ 2^3 * (2^9/(2^5+2^4+2^1))
in = 255*3*3*ones(10,10);
out = conv2(in, true(9, 1), 'valid'); %U12.0
out = fxp_utils.shift(out, 3); %U9.0
out = conv2(out, true(1, 9), 'valid'); %U13.0
out = fxp_utils.shift(out * (2^5 + 2^4 + 2^1), 9+3);  %U10.0
out = fxp_utils.clipU(out, 8); %U8.0
disp(out)

%% normalize signal in fixed point.
nbits_in = 8;
nbits_out = 9;
in_maxval  = nbits_in^2-1;
out_maxval = nbits_out^2-1;
x = 0:in_maxval;

th1_float = 0.2;
th2_float = 0.7;

th1_fxp = th1_float * in_maxval;
th2_fxp = th2_float * in_maxval;
slope_float = out_maxval / (th2_fxp - th1_fxp);
slope_frac_bits = 2;
slope_int_bits = 8;
slope_fxp = fxt_utils.float2fix(slope_float, slope_int_bits, slope_frac_bits);
y = CLIP(SHIFT_ROUND((x - th1_fxp) * slope_fxp, SLOPE_FRAC_BITS), 0, out_maxval);

figure; plot(y);

%% TODO - 
%spatial control: strengthen sharpening power in peripheral areas. 
%In order to bypass: ISP_API.power_spatial_control_slope=0 
%option 1: - only increase
pd = CLIP(SHIFT_ROUND((distance - ISP_API.power_spatial_control_th) * ISP_API.power_spatial_control_slope  , P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS ), 0, ISP_API.power_spatial_control_multiply_factor); %U0.(P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS) ->U0.6
sharpening_power_texture = min( SHIFT(sharpening_power_texture.*(P.HWP_POWER_SPATIAL_CONTROL_MAX_VAL + pd),P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4
sharpening_power_edges   = min( SHIFT(sharpening_power_edges  .*(P.HWP_POWER_SPATIAL_CONTROL_MAX_VAL + pd),P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4
% option 2: - decrease and increase using additional register
% ISP_API.power_spatial_control_mode = -1; %0=bypass, -1=decrease in peripherial , 1=increase in peripherials.
% pd = CLIP(SHIFT_ROUND((distance - ISP_API.power_spatial_control_th) * ISP_API.power_spatial_control_slope  , P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS ), 0, ISP_API.power_spatial_control_multiply_factor); %U0.(P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS) ->U0.6
% sharpening_power_texture = min( SHIFT(sharpening_power_texture.*(P.HWP_POWER_SPATIAL_CONTROL_MAX_VAL + ISP_API.power_spatial_control_mode*pd),P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4
% sharpening_power_edges = min( SHIFT(sharpening_power_edges.*(P.HWP_POWER_SPATIAL_CONTROL_MAX_VAL + ISP_API.power_spatial_control_mode*pd),P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4
%third option: - decrease and increase using pd that is ranged to [0,2].
% ISP_API.power_spatial_control_th = 2200; %U13.0 (Same as distance)
% ISP_API.power_spatial_control_multiply_factor = -30; %S+0.(P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS)
% ISP_API.power_spatial_control_slope = -10; %S+0.(P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS)S+
% if( ISP_API.power_spatial_control_multiply_factor >0 )
%     pd = CLIP(SHIFT_ROUND((distance - ISP_API.power_spatial_control_th) * ISP_API.power_spatial_control_slope  , P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS ), 0 , ISP_API.power_spatial_control_multiply_factor); %U0.(P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS) ->U0.6
% else
%     pd = CLIP(SHIFT_ROUND((distance - ISP_API.power_spatial_control_th) * ISP_API.power_spatial_control_slope  , P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS ), -ISP_API.power_spatial_control_multiply_factor , 0); %U0.(P.HWP_POWER_SPATIAL_CONTROL_SLOPE_FRAC_BITS) ->U0.6
% end
% pd = P.HWP_POWER_SPATIAL_CONTROL_MAX_VAL + pd;
% sharpening_power_texture = min( SHIFT(sharpening_power_texture.*pd,P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4
% sharpening_power_edges = min( SHIFT(sharpening_power_edges.*pd,P.HWP_POWER_SPATIAL_CONTROL_FRAC_BITS ) , P.HWP_USM_POWER_MAX_VAL); %U(P.HWP_USM_POWER_INT_BITS).(P.HWP_USM_POWER_FRAC_BITS) -> U2.4



%% take functions from 
% C:\Users\mhadar\projects\early_blend_control\EBC_matlab_code\fxp_utils

%% exponenet approximation exp(-0.5*x.^2)
P.HWP_BLT_EXP_PREC  = 7;
P.HWP_BLT_EXP_MAX_VAL = 127;
a = (142 * 2^(P.HWP_BLT_EXP_PREC-7)) - floor(luma_dist_normalized/2); 
b = (47 * 2^(P.HWP_BLT_EXP_PREC-7)) - floor(luma_dist_normalized/2^3);
luma_weights = max(a,b);
luma_weights = CLIP( luma_weights , 0 , P.HWP_BLT_EXP_MAX_VAL); %U.(P.HWP_BLT_EXP_PREC)