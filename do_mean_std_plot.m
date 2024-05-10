
function [Score_vals, plot_data ]  =  do_mean_std_plot(spec_vals_temp , Block_DATA , mode_pairs_to_Use,labels,std_bar_size,display_plots,file_name,block_file_)

plot_data.spec_vals_temp  = spec_vals_temp ;
plot_data.Block_DATA = Block_DATA ;
plot_data.mode_pairs_to_Use = mode_pairs_to_Use;
plot_data.labels = labels;
plot_data.std_bar_size = std_bar_size;
plot_data.display_plots = display_plots;
plot_data.file_name = file_name;
plot_data.block_file_ = block_file_;

if display_plots(2) ==1
figure
end% if display_plots(2) ==1

val_nos_tmp = 1:16;


if display_plots(2) ==1
   
xBlanks = zeros(1, length(mode_pairs_to_Use));
axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));

file_name(find(file_name =='_')) = ' ';
block_file_(find(block_file_=='_')) = ' ';

title({['TEST:: ',file_name],['LB:: ',block_file_]})

hold on
end %if display_plots(2) ==1



for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));


if display_plots(2) ==1
errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
end%if display_plots(2) ==1

Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

if display_plots(2) ==1
plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)
legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');

end %if display_plots(2) ==1

Score_vals.Means_       =  Means_                              ;
Score_vals.Stds_        =  Stds_                               ; 
Score_vals.spec_vals_   =  spec_vals_temp(mode_pairs_to_Use)   ;

end %function do_mean_std_plot(spec_vals,Block_DATA)
