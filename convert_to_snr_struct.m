function old_ = convert_to_snr_struct(new_)

old_.RMS_boundaries      =  [new_.RMS_boundaries_options(new_.RMS_boundaries(1)),new_.RMS_boundaries_options(new_.RMS_boundaries(2)),new_.RMS_boundaries_options(new_.RMS_boundaries(3))];
old_.SNR_boundaries      =  [new_.SNR_boundaries_options(new_.SNR_boundaries(1)),new_.SNR_boundaries_options(new_.SNR_boundaries(2)),new_.SNR_boundaries_options(new_.SNR_boundaries(3))];
old_.LFN_boundaries      =  [new_.LFN_boundaries_options(new_.LFN_boundaries(1)),new_.LFN_boundaries_options(new_.LFN_boundaries(2)),new_.LFN_boundaries_options(new_.LFN_boundaries(3))];
old_.HFN_boundaries      =  [new_.HFN_boundaries_options(new_.HFN_boundaries(1)),new_.HFN_boundaries_options(new_.HFN_boundaries(2)),new_.HFN_boundaries_options(new_.HFN_boundaries(3))]; 
old_.exitation_freq_kHz  =  new_.exitation_freq_kHz_options(new_.exitation_freq_kHz);
old_.SNR_bandwidth_kHz   =  new_.SNR_bandwidth_kHz_options(new_.SNR_bandwidth_kHz);
old_.time_gate           =  new_.time_gate_options(new_.time_gate);
old_.diagonal_time_gate  =  new_.diagonal_time_gate_options(new_.diagonal_time_gate);

end