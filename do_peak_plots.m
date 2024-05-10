function do_peak_plots(SR,PP_string)
sub_plots_inds = [1,1 ; 2,1 ; 3,1 ; 2,2 ; 3,2 ; 3,2 ; 4,2 ; 4,2 ; 3,3; 3,4; 3,4; 3,4 ; 4,4 ; 4,4 ; 4,4 ; 4,4; 4,5; 4,5; 4,5; 4,5; 5,5; 5,5; 5,5; 5,5; 5,5];
fig_ = figure ;



for index = 1: length(SR)

title_ = remove_((SR{index}.file_name));
SB_= subplot( sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index );    


plot_data = SR{index}.plot_data{1};
dv          = plot_data.dv                        ;
mm33        = plot_data.mm33                      ;
lower_index = plot_data.lower_index                ;

upper_index = plot_data.upper_index                ;
max_ind    =  plot_data.max_ind                     ;
max_val    =  plot_data.max_val                ;
plot(dv,mm33,"Color",'b') 
hold on
plot( [dv(lower_index),dv(lower_index)],[min(mm33),max(mm33)  ],'r')
plot( [dv(upper_index),dv(upper_index)],[min(mm33),max(mm33)  ],'r')
plot(dv(max_ind), max_val,'o','markersize', 10 );
title ([title_,'; Pk = ',num2str(dv(max_ind)*1000),'mm'])
end% for index = 1: length(SR)

sgtitle( PP_string ) 
set(gcf, 'name', ['PEAKS: ',PP_string])



end %function do_peak_plots(SR)

