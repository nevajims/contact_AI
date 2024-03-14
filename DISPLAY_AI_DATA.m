function DISPLAY_AI_DATA(all_display_data , data_to_display,file_name)

fid = fopen(file_name, 'w');
show_on_console = 1;

% displays that bits you seect in      data_to_display
% put allthe disps in on output window
% data_to_display.display_txt = [1 1 1 1 1 1 1 1 1 1 1 ]     ;
% data_to_display.display_plots = [1 1 1]                    ; 
% DISPLAY_AI_DATA(output_,data_to_display )


if data_to_display.display_txt(1)== 1
%-----------------------------------------------------------
% DISP 1
fprintf(fid, all_display_data.txt{1});
if show_on_console == 1
fprintf(all_display_data.txt{1})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(2)== 1
%-----------------------------------------------------------
% DISP 2
fprintf(fid, all_display_data.txt{2});
if show_on_console == 1
fprintf(all_display_data.txt{2})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(3)== 1
%-----------------------------------------------------------
% DISP 3
fprintf(fid, all_display_data.txt{3});
if show_on_console == 1
fprintf(all_display_data.txt{3})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(4)== 1
%-----------------------------------------------------------
% DISP 4
fprintf(fid, all_display_data.txt{4});
if show_on_console == 1
fprintf(all_display_data.txt{4})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(5)== 1
%-----------------------------------------------------------
% DISP 5
fprintf(fid, all_display_data.txt{5});
if show_on_console == 1
fprintf(all_display_data.txt{5})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(6)== 1
%-----------------------------------------------------------
% DISP 6
fprintf(fid, all_display_data.txt{6});
if show_on_console == 1
fprintf(all_display_data.txt{6})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(7)== 1
%-----------------------------------------------------------
% DISP 7
fprintf(fid, all_display_data.txt{7});
if show_on_console == 1
fprintf(all_display_data.txt{7})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(8)== 1
%-----------------------------------------------------------
% DISP 8
fprintf(fid, all_display_data.txt{8});
if show_on_console == 1
fprintf(all_display_data.txt{8})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(9)== 1
%-----------------------------------------------------------
% DISP 9
fprintf(fid, all_display_data.txt{9});
if show_on_console == 1
fprintf(all_display_data.txt{9})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(10)== 1
%-----------------------------------------------------------
% DISP 10
fprintf(fid, all_display_data.txt{10});
if show_on_console == 1
fprintf(all_display_data.txt{10})
end
%-----------------------------------------------------------
end

if data_to_display.display_txt(11)== 1
%-----------------------------------------------------------
% DISP 11
fprintf(fid, all_display_data.txt{11});
if show_on_console == 1
fprintf(all_display_data.txt{11})
end
%-----------------------------------------------------------
end

if data_to_display.display_plots(1)== 1
%-----------------------------------------------------------
% PLOT 1
do_plot_1(all_display_data.plot_data{1})
%-----------------------------------------------------------
end

if data_to_display.display_plots(2)== 1
%-----------------------------------------------------------
% PLOT 2
do_plot_2(all_display_data.plot_data{2})
%-----------------------------------------------------------
end

if data_to_display.display_plots(3)== 1
%-----------------------------------------------------------
% PLOT 3
do_plot_3(all_display_data.plot_data{3} ,'SPECIFIC TEST mode plot',0.8)
%-----------------------------------------------------------
end

end %function DISPLAY_AI_DATA(all_display_data , one_to_display)







function do_plot_1(plot_data)
dv          = plot_data.dv                        ;
mm33        = plot_data.mm33                      ;
lower_index = plot_data.lower_index                ;

upper_index = plot_data.upper_index                ;
max_ind    =  plot_data.max_ind                     ;
max_val    =  plot_data.max_val                ;
% put this in a sub function

h_ = figure; 
plot(dv,mm33,"Color",'b') 
hold on
plot( [dv(lower_index),dv(lower_index)],[min(mm33),max(mm33)  ],'r')
plot( [dv(upper_index),dv(upper_index)],[min(mm33),max(mm33)  ],'r')

plot(dv(max_ind), max_val,'o','markersize', 10 );
title (['peak = ',num2str(dv(max_ind)*1000),'mm'])


end %function display_plot_1(plot_data)






function   do_plot_2(plot_data)

spec_vals_temp    = plot_data.spec_vals_temp ;
Block_DATA        = plot_data.Block_DATA ;
mode_pairs_to_Use = plot_data.mode_pairs_to_Use ;

labels            = plot_data.labels  ;
std_bar_size      = plot_data.std_bar_size  ;
display_plots     = plot_data.display_plots  ;
file_name         = plot_data.file_name  ;
block_file_       = plot_data.block_file_ ;

figure
val_nos_tmp = 1:16;
  
xBlanks = zeros(1, length(mode_pairs_to_Use));
axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));

file_name(find(file_name =='_')) = ' ';
block_file_(find(block_file_=='_')) = ' ';

title({['TEST:: ',file_name],['LB:: ',block_file_]})
hold on


for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));


errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')

Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)
legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');



end %function do_mean_std_plot(spec_vals,Block_DATA)


function do_plot_3(interp_data,title_,db_range) 
figure
colormap default;
surf(interp_data);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
colorbar;

title(title_)

    sf = 50 / 4;
    offset = 50 / 50;

modes_temp = [1,2,3,4];

for ii = 1:4
    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');

    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i',modes_temp(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)

end %function plot_interp_data(interp_data,options) 
