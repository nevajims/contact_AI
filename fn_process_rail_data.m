function rail_tester_out = fn_process_rail_data(rail_tester_in, options)


default_options  = get_default_options() ;

if nargin < 2
    options = [];
end %if nargin < 2

options = fn_set_default_fields(options, default_options);
%------------------------------------------------------------------------------------------------
% note: throughout this function, ONLY the proc_data field in rail_tester is changed
% Other fields including raw_data etc. NEVER get modified, so file can be saved after processing
% without worrying about corrupting original information
%------------------------------------------------------------------------------------------------
rail_tester_out = rail_tester_in;
if isfield(rail_tester_out, 'proc_data')
    rmfield(rail_tester_out, 'proc_data');
end

%force single frequency mode shape matrix processing if simulating working in time domain
if options.ms_matrix_apply_as_time_shift
   options.ms_matrix_calc_method = 1; %to force single mode shape matrix at filter freq only
end

%set up frequency for mode shape calc if only using single freq
if options.ms_matrix_calc_method == 1
    options.ms_matrix_calc_freqs = options.freq_filter;
end

%some shortcut variables to protect original fields
raw_data = rail_tester_out.raw_data;
disperse = rail_tester_out.disperse;
array = rail_tester_out.array;

% array = rmfield(array, 'tx_rows');
% array = rmfield(array, 'rx_rows');
% array = rmfield(array, 'trans_pos_phasings');
% array.trans_pos_orientations = array.trans_pos_orientations(:);

input_signal = rail_tester_out.input_signal;

%zero out dead time if required
if options.raw_data_zero_dead_time > 0
    raw_data = fn_zero_dead_zone(...
        raw_data, ...
        options.raw_data_zero_dead_time, ...
        options.suppress_display);
end

%removal of p/e columns if required
if (options.raw_data_ignore_pulse_echo == 1)
    raw_data = fn_remove_pulse_echo_data(raw_data, options.suppress_display);
end

%convert to frequency domain
raw_data = fn_convert_to_freq_domain(...
    raw_data, ...
    options.suppress_display);

%coupling compensation if required
if options.raw_data_coupling_comp ~= 0
    raw_data = fn_coupling_comp(raw_data, array, options);
end

%sort out the mode indices for processed data
proc_data.tx_mode = ones(length(options.ms_matrix_modes_to_use),1) * options.ms_matrix_modes_to_use;
proc_data.rx_mode = proc_data.tx_mode';
proc_data.tx_mode = proc_data.tx_mode(:);
proc_data.rx_mode = proc_data.rx_mode(:);
proc_data.tx_dir = [ones(length(proc_data.tx_mode),1);-ones(length(proc_data.tx_mode),1)];
proc_data.rx_dir = [ones(length(proc_data.tx_mode),1);-ones(length(proc_data.tx_mode),1)];
if options.ms_matrix_bidi_calc;
    proc_data.tx_dir = [proc_data.tx_dir; proc_data.tx_dir];
    proc_data.rx_dir = [proc_data.rx_dir; flipud(proc_data.rx_dir)];
    proc_data.tx_mode = [proc_data.tx_mode; proc_data.tx_mode; proc_data.tx_mode; proc_data.tx_mode];
    proc_data.rx_mode = [proc_data.rx_mode; proc_data.rx_mode; proc_data.rx_mode; proc_data.rx_mode];
else
    proc_data.tx_mode = [proc_data.tx_mode; proc_data.tx_mode];
    proc_data.rx_mode = [proc_data.rx_mode; proc_data.rx_mode];
end

%frequency domain processing
raw_data = fn_filter_freq_domain_data( ...
    raw_data, ...
    input_signal, ...
    array.delay, ...
    options.freq_comp_for_input_signal, ...
    options.freq_filter_on, ...
    options.freq_filter, ...
    options.freq_filter_bandwidth, ...
    options.suppress_display);

%build inverse mode shape matrix at frequency(s) required. This is the new
%version of the function. To use the old one use fn_inv_mode_shape_matrices
inv_mode_shapes = fn_inv_mode_shape_matrices3D(...
    raw_data, ...
    proc_data, ...
    array, ...
    disperse, ...
    options.ms_matrix_calc_freqs, ...
    options.ms_matrix_modes_to_use, ...
    options.suppress_display);

%do the mode extraction
temp_freq_data = fn_mode_extract_freq_dom(...
    inv_mode_shapes, ...
    options.ms_matrix_calc_freqs, ...
    raw_data, ...
    proc_data, ...
    options.ms_matrix_apply_as_time_shift, ...
    options.ms_matrix_time_step_size, ...
    options.ms_matrix_allow_neg_amps, ...
    options.suppress_display);
%convert from freq to distance
if options.dispersion_compensation
    %TODO - will go directly from freq to dist
    %must remember to make sure modal_vgrs is generated in proc_data
    %for use with warping
else
    %first from freq to time domain ...
    temp_time_data = fn_convert_freq_to_time_dom( ...
        temp_freq_data, ...
        options.suppress_display);
    %... and then from time to distance
    proc_data = fn_convert_time_to_dist( ...
        temp_time_data, ...
        proc_data, ...
        disperse, ...
        options.ms_matrix_modes_to_use, ...
        options.freq_filter, ...
        options.suppress_display);
end

%warping - parameters for no warp
proc_data.current_warps = ones(1, size(proc_data.dist_data, 2));
proc_data.modal_warps = ones(1, max([proc_data.tx_mode; proc_data.rx_mode]));
if options.warp_factor
    %manual warps
    switch options.warp_factor 
        case 1
            proc_data.modal_warps = options.manual_warps;
        case 2
            proc_data = fn_smart_warps(proc_data, ...
                options.smart_warp_ref_mode, ...
                options.smart_warp_trial_range, ...
                options.suppress_display);
    end
    proc_data = fn_apply_dist_warps(proc_data, options.suppress_display);
end

%assign processed data field
rail_tester_out.proc_data = proc_data;
rail_tester_out.proc_data.inv_mode_shapes = inv_mode_shapes; %just to see what this looks like
end

function default_options  = get_default_options()
%default options - filter
default_options.freq_filter_on = 1;
default_options.freq_filter = 50e3;
default_options.freq_filter_bandwidth = 3.5e3;%filter half bandwidth to -40 dB points
default_options.freq_comp_for_input_signal = 1;
%default options - raw data
default_options.raw_data_ignore_pulse_echo = 0;
default_options.raw_data_coupling_comp = 2;
default_options.raw_data_zero_dead_time = 0;
%default options - mode shape matrix calculation - what modes and directions are included
default_options.ms_matrix_modes_to_use = [1,2,3,4];%modes used in calculation of matrices
default_options.ms_matrix_bidi_calc = 0; %turn on to include transmit in +ve direction and receive in +ve direction combos in calc
%default options - mode shape matrix calculation - single or multi-frequency
default_options.ms_matrix_calc_method = 1; %1 filter frequency; 2 linear interpolation between matrices calculated at ms_matrix_calc_freqs
default_options.ms_matrix_calc_freqs = linspace(47.5e3,52.5e3,11); %frequencies to calc mode shape matrix at for linear interpolation
%default options - mode shape matrix calculation - if you want to simulate pure time domain processing
default_options.ms_matrix_apply_as_time_shift = 0; %turn on to do freq domain processing, but applied as time rather than phase shifts
default_options.ms_matrix_time_step_size = 0; %if non-zero and doing time shifts, this sets the smallest integral multiple of time shifts allowed
default_options.ms_matrix_allow_neg_amps = 1; %if non-zero and doing time shifts, time shifts of between pi and 2pi are implemented as pi less combined with a negative amplitude
%default options - other
default_options.dispersion_compensation = 0; %turn on for dispersion compensation - not implemented!!
default_options.warp_factor = 1; %0 - no warping, 1 - use the manual warps, 2 - smart warp (I haven't tested this);
%default_options.manual_warps = ones(1, max(default_options.ms_matrix_modes_to_use));
default_options.manual_warps = [1.02,1.02,1.02,0.952]; %added this to see how it works, based on experimental result.
%default_options.manual_warps = [1.11,1.05,1.01,1.13]; %These are the warps
%for the pogo models
default_options.smart_warp_ref_mode = 3;
default_options.smart_warp_trial_range = linspace(0.9, 1.1, 21);
default_options.suppress_display = 0;
default_options.show_coupling_graph = 1;
end
