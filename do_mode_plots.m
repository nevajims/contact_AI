function do_mode_plots(SR,PP_string)
%db_range = 0.8      ; 
db_range = 1.1;
fig_  = figure      ;
sub_plots_inds = [1,1 ; 2,1 ; 3,1 ; 2,2 ; 3,2 ; 3,2 ; 4,2 ; 4,2 ; 3,3; 3,4; 3,4; 3,4 ; 4,4 ; 4,4 ; 4,4 ; 4,4; 4,5; 4,5; 4,5; 4,5; 5,5; 5,5; 5,5; 5,5; 5,5];

for index = 1: length(SR)
subplot(sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index)    

title_ = remove_((SR{index}.file_name));
interp_data = (SR{index}.plot_data{3});

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
end %for index = 1: length(SR)
sgtitle(PP_string ) 
set(gcf, 'name', ['MODEMAPS: ',PP_string])


end  %function do_mode_plots(SR)
