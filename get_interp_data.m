
function interp_data = get_interp_data(slice_data,grid_size_to_plot)
if grid_size_to_plot > 4
    x = linspace(1,4,grid_size_to_plot);
    y = linspace(1,4,grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:4],[1:4],slice_data,xi,yi);
else
    interp_data = slice_data;
end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;
end % function interp_data = get_interp_data(slice_data,options,grid_size_to_plot)
