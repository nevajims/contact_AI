function do_stat_plots(SR,PP_string)
sub_plots_inds = [1,1 ; 2,1 ; 3,1 ; 2,2 ; 3,2 ; 3,2 ; 4,2 ; 4,2 ; 3,3; 3,4; 3,4; 3,4 ; 4,4 ; 4,4 ; 4,4 ; 4,4; 4,5; 4,5; 4,5; 4,5; 5,5; 5,5; 5,5; 5,5; 5,5];
fig_ =figure ;

for index = 1: length(SR)
% disp(num2str(index))

SB_= subplot( sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index );    


title_ = remove_((SR{index}.file_name));


plot_data = SR{index}.plot_data{2} ;

spec_vals_temp    = plot_data.spec_vals_temp ;
Block_DATA        = plot_data.Block_DATA ;
mode_pairs_to_Use = plot_data.mode_pairs_to_Use ;
labels            = plot_data.labels  ;
std_bar_size      = plot_data.std_bar_size  ;
block_file_       = plot_data.block_file_ ;

val_nos_tmp = 1:16;

xBlanks = zeros(1, length(mode_pairs_to_Use));


subplot(SB_)
hold on


title(['TEST:: ',title_])

for index_2 = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index_2},1,numel(Block_DATA.mean_tag_modes_{index_2}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index_2},1,numel(Block_DATA.std_tag_modes_{index_2}));
errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)

end %for index_2 = 1: length(Block_DATA.Labels_)

legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');


xlim([0,length(mode_pairs_to_Use)+1])
xticklabels(labels(mode_pairs_to_Use))
xticks(1: length(mode_pairs_to_Use))

%axes( 'XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));


end % for index = 1: length(SR)
sgtitle( PP_string ) 
set(gcf, 'name', ['STATS: ',PP_string])



end %function do_peak_plots(summary_results)

