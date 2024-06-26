function Block_DATA = compile_data_block(Percentage_Peak, Labels_)

% Assume its finding the peak then going back and taking a fraction of that
% Labels_ = {'not cracked','cracked'} -  default
% Labels_ = {'zero','one','two','three','four','five'}
% Choose a block of files and go through them  1 by one and compile the data

% compile_data_block( 45 , {'not cracked','cracked'})
% compile_data_block( 45 , {'zero','one','two','three','four','five'})
% compile_data_block( 45 , {'not cracked','small','med','large'})
% compile_data_block( 45 , {'Clear','small','med','large'})
%                     0/1  2/3  4  5
% compile_data_block( 45 , {'No Crack','Crack','Large Crack'})
%                     0  (1,2,3,4)  5

Peak_method = 3;
P_W_D = pwd;
cd('P:\GITHUBS\AIDATA')


%cd ('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[chosen_files , path]  =  uigetfile('*.*','Select the INPUT DATA FILE(s)','MultiSelect','on');

for index = 1 : length(chosen_files)
    [traces{index}, Peak_loc(index),file_{index} , crack_mode_{index} , tag_label_index(index)] =  Get_single_test_values (Peak_method, Percentage_Peak,chosen_files{index},path,Labels_);    
end %for index = 1 : length(chosen_files)

% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
Block_DATA.Labels_           = Labels_              ; 
Block_DATA.crack_mode_       = crack_mode_          ;
Block_DATA.tag_label_index   = tag_label_index      ; 
Block_DATA.Peak_loc          = Peak_loc             ;
Block_DATA.file_             = file_                ;
Block_DATA.traces            = traces               ;
Block_DATA.Percentage_Peak   = Percentage_Peak      ;
Block_DATA.Peak_method       = Peak_method          ;
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% this goes in the predict part
%{

for index = 1:length(Labels_)
disp(['Tag = ',Labels_{index} ,'.'])
tag_indicies                   = find(tag_label_index == index);
tag_modes_ =   crack_mode_(:,:,tag_indicies);
mean_temp = mean(tag_modes_ , 3)
mean_tag_modes_{index}         = mean_temp;
std_temp = std(tag_modes_,0,3)
std_tag_modes_{index}          = std_temp;
interp_data = get_interp_data(mean_tag_modes_{index},50);
plot_interp_data(interp_data,[Labels_{index},':: mean values(normalised to 1-1)'],0.8)
interp_data = get_interp_data(std_temp./mean_temp,50);
plot_interp_data(interp_data,[Labels_{index},':: std over mean   '],0.8)
end %for index = 1:length(Labels_)
%}
%Block_DATA.mean_tag_modes_     =  mean_tag_modes_  ;
%Block_DATA.std_tag_modes_      =  std_tag_modes_   ;

% labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'} 

save([path,'Block_data_',num2str(Percentage_Peak),'_PP_',num2str(length(Labels_)) , '_L', num2str(length(chosen_files)),'_DV.mat'],'Block_DATA')
cd(P_W_D)

end %function compile_data_block(Percentage_of_peak, Labels_)
% ----------------------------------------------------------------
% ----------------------------------------------------------------

function plot_interp_data(interp_data,title_,db_range) 
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


function [traces,Peak_loc,file_ ,crack_mode, tag_label_index] =  Get_single_test_values (P_P_P, Percentage_Peak,file_,path_,Labels_)

disp(['File Name:  ', file_])
[tag_label_index, ~ ] = listdlg('ListString',Labels_,'SelectionMode','single');
tag_label = Labels_{tag_label_index};

plot_options  = load_structure_from_file('plot_options_.dat');
dummy =  open(strcat(path_,file_));

if  isfield (dummy, 'rail_tester')==1
grid_data = fn_get_grid_data(dummy.rail_tester , plot_options);
mode_map = grid_data.data_stack;
mm33  = squeeze(mode_map(3,3,:))     ;
mm22  = squeeze(mode_map(2,2,:))     ;
dv = grid_data.distance_vector       ;   

traces.mm33= mm33   ;
traces.mm22= mm22   ;
traces.dv  = dv     ; 

[max_ind, max_val,h_]  = get_point_for_mode_map(mm33,dv,P_P_P,Percentage_Peak);

figure(h_)

plot(dv(max_ind), max_val,'o','markersize', 10 );
title ([tag_label,', peak = ',num2str(dv(max_ind)*1000),'mm'])

fn_plot_grid_data(grid_data, plot_options ,dv(max_ind))

crack_mode = grid_data.data_stack(:,:,max_ind);
% crack_mode = crack_mode./crack_mode(1,1);
%key_mode_values = [crack_mode(3,1),crack_mode(2,4),crack_mode(1,2),crack_mode(4,4)];
%Values_.key_mode_values = key_mode_values          ;

Peak_loc        =  dv(max_ind)*1000        ;

% disp('--------------------------------------------')
% disp([file_,'(',Values_.tag_label,')'])
% disp('--------------------------------------------')
% crack_mode
% disp (['key mode values (3/1 2/4 1/2  4/4 ./  1/1)::   ',num2str(key_mode_values(1)),', ',num2str(key_mode_values(2)),', ',num2str(key_mode_values(3)),', ' ,num2str(key_mode_values(4)),'.'])
% disp('--------------------------------------------')

else
disp('no rail_tester field in structure - data is not in theprocessed format'  )  
Values_         =  0     ;
crack_mode      = 'void' ;
tag_label_index = 'void' ;
end %if  isfield (dummy, 'rail_tester')==1



end    % function [mode_values   ] =  Get_mode_values_from_a_test ()

%--------------------------------------------------------------------------------------------------------------
%--------------------------------------------------------------------------------------------------------------

function [max_ind, max_val,h_]  = get_point_for_mode_map(mm33,dv,P_P_P,Percentage_Peak )
switch (P_P_P)
    case (2)
range_selected_ok = 0;
while range_selected_ok == 0
h_ = figure; 
plot(dv,mm33,"Color",'b') 
title (' Select lower and upper bound of the peak' )
hold on 
for index = 1:2     
[x_(index),~] = ginput(1); 
plot( [x_(index),x_(index) ],[min(mm33),max(mm33)  ],'r')
end  %for index = 1 : 2    
answer_ = questdlg('limits ok?' ,'Yes','No');
switch(answer_)
      case('Yes')
[~,lower_index]  =   min(abs(dv - x_(1))) ; 
[~,upper_index]  =   min(abs(dv - x_(2))) ; 
[max_val,temp_ind]  =  max(mm33(lower_index:upper_index)); 
max_ind = temp_ind + lower_index - 1  ;

range_selected_ok = 1;
    otherwise
  % try again
close (h_)  
end %switch(answer_)


end %  while range_selected_ok == 0
 
case (1) 
point_selected = 0;
while point_selected == 0
    h_ = figure; 
plot(dv,mm33,"Color",'b') 
title ('Select  point' )
hold on 
[x_, y_] = ginput(1); 
plot(x_ , y_ , 'ro' )

answer_ = questdlg('limits ok?' ,'Yes','No');

switch(answer_)
      case('Yes')
[~,max_ind]  =   min(abs(dv - x_));
max_val = y_;
point_selected = 1;
      otherwise
  % try again
close (h_)  
end %switch(answer_)
end % while point_selected == 0

case (3)
range_selected_ok = 0;

while range_selected_ok == 0
h_ = figure; 
plot(dv,mm33,"Color",'b') 
title (' Select lower and upper bound of the peak' )
hold on 
for index = 1:2     
[x_(index),~] = ginput(1); 
plot( [x_(index),x_(index) ],[min(mm33),max(mm33)  ],'r')
end  %for index = 1 : 2    
answer_ = questdlg('limits ok?' ,'Yes','No');
switch(answer_)
      case('Yes')
[~,lower_index]  =   min(abs(dv - x_(1))) ; 
[~,upper_index]  =   min(abs(dv - x_(2))) ; 
[max_val,temp_ind]   =  max(mm33(lower_index:upper_index)); 
max_ind              =  temp_ind + lower_index - 1  ;
% go back from max index until %value is reached 
target_val =  max_val * (Percentage_Peak / 100) ;  
Perc_Val_found = 0;

while Perc_Val_found ==0
max_ind = max_ind - 1;
if mm33(max_ind)   <= target_val
max_val = mm33(max_ind) ;
Perc_Val_found = 1;    
end
% target_val
end %while Perc_Val_found ==0
range_selected_ok = 1;
    otherwise
  % try again
close (h_)  
end %switch(answer_)
end % while range_selected_ok == 0
% (1)  Select the left and right as before
% (2)  Find the peak 
% (3)  Get a percentage  
% Percentage_Peak  
end %switch (Point_or_Peak)

end %function [max_ind), max_val]  = get_point_for_mode_map(mm33,dv)

%   -------------------------------------------------   
%   3/1   ---   2/4    ----  1/2    ------    4/4
%   ----------------Divide everything by 4/1
%  what we see
%  3/1 an 1/1  aty  the same-  normalise with this
% change themost  :  4/2--2/4   and  4/4  ---   
% ----------------------------------
% 2 values and normalise with 1/1  normoilse to 3/3 as this is the principle
% ----------------------------------






