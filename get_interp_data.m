
function interp_data = get_interp_data(slice_data,grid_size_to_plot)
%keyboard


if grid_size_to_plot > 4
    x = linspace(1,size(slice_data,1),grid_size_to_plot);
    y = linspace(1,size(slice_data,2),grid_size_to_plot);
     %x = linspace(1,4,grid_size_to_plot);
    %y = linspace(1,4,grid_size_to_plot);
     
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:size(slice_data,1)],[1:size(slice_data,2)],slice_data,xi,yi);
else
    interp_data = slice_data;

end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;

end % function interp_data = get_interp_data(slice_data,options,grid_size_to_plot)
