function [grid_data ] = fn_get_grid_data(rail_tester , options)
% ---------------------------------------------------------------------------------------------------------------------------------
% JIM 2021 // 2022
% ---------------------------------------------------------------------------------------------------------------------------------
% This will produce a stack of grid matrixes which can the be accessed with
% a slider plot -  dont do the db or the grid interp at this stage - and
% use the distance resoltion in the data (no dist interpolation)
% Then have a seperate function with plots using this data (and does the grd interp + db  and have the option to interpolate on distance   
% Interpolate_on_distance  needs to be an option which is set in the files
% options  -  come from the plot file
% real_length  -   is the start and the end of the length data - comes from the hardware file
% dist_tol_max_mean    distance tol is max(1) or mean(2) 
% ---------------------------------------------------------------------------------------------------------------------------------
% TO DO
% ---------------------------------------------------------------------------------------------------------------------------------
% (1) Get the single pos values for  all the poss options
% (2) put it into a stack
% (3) plot a single instance (your choice)
% (4) Introduce the different options-   interpolations / dB /    other ?   
% ---------------------------------------------------------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------------------------------------------------
% only the first has values

default_options = get_default_options()                    ;                % function defined below %
options = set_default_fields(options, default_options)     ;
real_length = rail_tester.real_length                      ;

if ~isfield(rail_tester, 'proc_data')
    disp('No processed data available!');
    grid_data = NaN ;
    return ;          % abandon at this point
end %if ~isfield(rail_tester, 'proc_data')

neg_indices = find(rail_tester.proc_data.dist < abs(real_length(1)))   ;
pos_indices = find(rail_tester.proc_data.dist < abs(real_length(1)))   ;
pos_indices = pos_indices(2:end)                                       ;    % remove the double zero

all_indices = [flipud(neg_indices);pos_indices] ;   % the indices is refereing to different vectors for the +ve and -ve parts   
distance_vector = [(-1 * rail_tester.proc_data.dist(flipud(neg_indices)))  ;  rail_tester.proc_data.dist(pos_indices)]        ; 
dir_vector = [-1*ones(size(neg_indices));ones(size(pos_indices))]                                                             ;  
[tx_mode, rx_mode] = meshgrid(options.modes, options.modes)                                                                   ;
data_stack =  zeros([size(tx_mode),length(distance_vector)])                                                                  ;
data_stack_temp =  zeros(size(tx_mode))                                                                                       ;                                                                                     

for index = 1: length(distance_vector)

distance_temp = distance_vector(index)                  ;    
dir =  dir_vector(index)                                ;

for index_2 = 1:length(tx_mode(:))
    
    jj = find((rail_tester.proc_data.tx_mode == tx_mode(index_2)) ...
        & (rail_tester.proc_data.rx_mode == rx_mode(index_2)) ...
        & (rail_tester.proc_data.tx_dir == dir) ...
        & (rail_tester.proc_data.rx_dir == dir));
    if ~isempty(jj)
        if options.dist_tol <= 0
            
% How do you get the indices of               
% HERE ------------------

       switch   (options.interp_or_val)   
       
           case(1)
            data_stack_temp (index_2) = interp1(rail_tester.proc_data.dist, abs(rail_tester.proc_data.dist_data(:, jj)), abs(distance_temp), 'linear');
           case(2)
            data_stack_temp(index_2) = rail_tester.proc_data.dist_data(:, jj);
       
       end %switch   (interp_or_val)   
       
        else
            
            i1 = min(find(rail_tester.proc_data.dist > abs(distance_temp) - options.dist_tol/2))              ;
            i2 = max(find(rail_tester.proc_data.dist < abs(distance_temp) + options.dist_tol/2))              ;
        
        switch (options.max_or_mean)
            case(1)            
            data_stack_temp(index_2) = max(abs(rail_tester.proc_data.dist_data(i1:i2, jj)));
            case(2)            
            data_stack_temp(index_2) = mean(abs(rail_tester.proc_data.dist_data(i1:i2, jj)));
        end %switch (options.max_or_mean)
                
        end %if options.dist_tol <= 0
    end %if ~isempty(jj)
end %for index_2 = 1:length(tx_mode(:))

data_stack(:,:,index) = data_stack_temp(:,:);

end % for index = 1: length(distance_vector)

grid_data.data_stack           = data_stack          ; 
grid_data.distance_vector      = distance_vector     ; 

%------------------------------------------------
% find  all the data within the 'real length' range
% Start the loop for all the distances
% remove the interpolation part  
%------------------------------------------------
%------------------------------------------------
%------------------------------------------------

end  %function grid_data = fn_get_grid_data(   )


function  default_options = get_default_options()
default_options.norm_to_what = 1   ;  % 1 - normalised to maximum in map, 2 = normalised to maximum in data
default_options.db_range = 30      ; 
default_options.dist_tol = 0.2     ;  % distance tolerance band around nominal distance to consider set to zero for exact interpolation
default_options.grid_size = 50     ;
default_options.modes = [1,2,3,4]  ;
options.interp_or_val = 1          ;
end %function  default_options = get_default_options()




