function  fn_plot_grid_data(varargin)
% function   fn_plot_grid_data(grid_data,options,distance_to_plot )
% need to take the variables grid size and db_range out of the options settings
% need topass in the figure handle 

switch(nargin)
    case(1)
    plot_data_stucture =   varargin{1};
    grid_size_to_plot  =   plot_data_stucture.current_grid_size;  
    db_range_to_plot   =   plot_data_stucture.current_db_range;
    distance_to_plot   =   plot_data_stucture.current_distance; 
    grid_data          =   plot_data_stucture.grid_data;
    options            =   plot_data_stucture.plot_options;
    figure_handle      =   plot_data_stucture.fig_handle; 
    
    case(3)        
    grid_data         =   varargin{1}         ;
    options           =   varargin{2}         ;
    distance_to_plot  =   varargin{3}         ;
    db_range_to_plot  =   options.db_range    ;
    grid_size_to_plot =   options.grid_size   ;
    figure_handle     =   figure              ;
end %switch(nargin)

if distance_to_plot < min(grid_data.distance_vector)
distance_to_plot = min(grid_data.distance_vector);
end %if distance_to_plot < min(grid_data.distance_vector)
    
if distance_to_plot > max(grid_data.distance_vector)
distance_to_plot = max(grid_data.distance_vector);
end %if distance_to_plot > max(grid_data.distance_vector)
   
[slice_data,plot_distance]  = get_slice_data(grid_data,options,distance_to_plot,db_range_to_plot);  

interp_data = get_interp_data(slice_data,options,grid_size_to_plot);

plot_interp_data(interp_data,options,plot_distance,db_range_to_plot,grid_size_to_plot,figure_handle); 
end  % Function   fn_plot_grid_data   (grid_data , distance_vector)  


function [slice_data,plot_distance] = get_slice_data(grid_data,options,distance_to_plot,db_range_to_plot)

[tol_ , plot_index] = min(abs(grid_data.distance_vector-distance_to_plot));
plot_distance = round(( tol_ + distance_to_plot )*1000)/1000;
slice_data = grid_data.data_stack(: , : , plot_index);

if options.norm_to_what == 1
    slice_data = slice_data / max(max(abs(slice_data)));
 else
    slice_data = slice_data / max(abs(grid_data.data_stack(:)));
end %if options.norm_to_what == 1

slice_data = 20 * log10(slice_data) + db_range_to_plot                ;
slice_data( find(slice_data < 0)                 ) = 0                ;
slice_data( find(isnan(slice_data) | isinf(slice_data))) = 0          ;

end %function slice_data = get_slice_data(grid_data,options,distance_to_plot)

function interp_data = get_interp_data(slice_data,options,grid_size_to_plot)
if grid_size_to_plot > length(options.modes)
    x = linspace(1,length(options.modes),grid_size_to_plot);
    y = linspace(1,length(options.modes),grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:length(options.modes)],[1:length(options.modes)],slice_data,xi,yi);
else
    interp_data = slice_data;
end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;


end %function interp_data = get_interp_data(slice_data,options);

function plot_interp_data(interp_data,options,plot_distance,db_range_to_plot,grid_size_to_plot,figure_handle) 

figure(figure_handle)
colormap default;
surf(interp_data);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range_to_plot]);
colorbar;
title(['Distance: ',num2str(plot_distance*1000),'mm']);

if grid_size_to_plot > length(options.modes)
    sf = grid_size_to_plot / length(options.modes);
    offset = grid_size_to_plot / 50;
else
    sf = 1;
    offset = length(options.modes) / 50;
end

for ii = 1:length(options.modes)

    a = text((ii - 0.5) * sf + 1, - offset + 1, sprintf('%i', options.modes(ii)));
    set(a, 'HorizontalAlignment', 'center');
    set(a, 'VerticalAlignment', 'top');
 
    a = text(-offset + 1, (ii - 0.5) * sf + 1, sprintf('%i', options.modes(ii)));
    set(a, 'HorizontalAlignment', 'right');
    set(a, 'VerticalAlignment', 'middle');

end % for ii = 1:length(options.modes)

end %function plot_interp_data(interp_data,options) 





