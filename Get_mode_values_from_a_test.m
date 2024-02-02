function [Values_ ,file_ ] =  Get_mode_values_from_a_test (P_P_P, Percentage_Peak,search_limits,FILE_TO_PREDICT,display_plots)

plot_options  = load_structure_from_file('plot_options_.dat');

if isnan(FILE_TO_PREDICT)
P_W_D =  pwd;
cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[file_,path_]=uigetfile();

% Need Tag
% P_P_P           1 = point ;    2 = peak   ;  3 = percentage PEAK;
% Percentage_Peak                           =      45        ;    
% tag_label = questdlg(['What label for ',file_,'.'], ...
% 'Labelling test', ...
% Not Cracked','Cracked','Not Cracked');
dummy =  open(strcat(path_,file_));
cd (P_W_D)
else
dummy =  open(strcat(FILE_TO_PREDICT));
file_ = FILE_TO_PREDICT(max(strfind(FILE_TO_PREDICT,'\'))+1:end);
end

grid_data = fn_get_grid_data(dummy.rail_tester , plot_options);
mode_map = grid_data.data_stack;
mm33    = squeeze(mode_map(3,3,:))     ;
mm22    = squeeze(mode_map(2,2,:))     ;

dv = grid_data.distance_vector       ;   
[max_ind, max_val]  = get_point_for_mode_map(mm33,dv,P_P_P,Percentage_Peak,search_limits,display_plots);


if display_plots(2)==1
h_2 = figure;
subplot(1,2,1)
title('33')
plot(dv,mm33,"Color",'b')
hold on
plot( [dv(max_ind),dv(max_ind) ],[min(mm33),max(mm33)  ],'r')
subplot(1,2,2)
title('22')
plot(dv,mm22,"Color",'b')
hold on
plot( [dv(max_ind),dv(max_ind) ],[min(mm22),max(mm22)  ],'r')
end


if display_plots(3) ==1
fn_plot_grid_data(grid_data, plot_options ,dv(max_ind))
end %if display_plots(3) ==1


crack_mode = grid_data.data_stack(:,:,max_ind);
crack_mode = crack_mode./crack_mode(1,1);

% key_mode_values = [crack_mode(1,3),crack_mode(2,2),crack_mode(2,4),crack_mode(3,1),crack_mode(4,2),crack_mode(4,4)];

%Values_.key_mode_values = key_mode_values          ;

Values_.crack_mode      = crack_mode;
Values_.Peak_loc        =  dv(max_ind)*1000        ;
Values_.file_           = file_;

% Values_.tag_label = tag_label;

%disp('--------------------------------------------')
%disp(['FILE:', file_ ,', LOCATION:', path_ ])
%disp('--------------------------------------------')
%crack_mode
%disp (['key mode values (1/3 2/2 2/4 3/1 4/2 4/4 ./ 1/1)::   ',num2str(key_mode_values(1)),', ',num2str(key_mode_values(2)),', ',num2str(key_mode_values(3)),', ' ,num2str(key_mode_values(4)),', ', num2str(key_mode_values(5)),',',num2str(key_mode_values(6))'.'])
%disp('--------------------------------------------')




end    % function [mode_values   ] =  Get_mode_values_from_a_test ()

%--------------------------------------------------------------------------------------------------------------
%--------------------------------------------------------------------------------------------------------------
%--------------------------------------------------------------------------------------------------------------

function [max_ind, max_val]  = get_point_for_mode_map(mm33,dv,P_P_P,Percentage_Peak, search_limits,display_plots)

if isnan(search_limits)

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

else
[~,lower_index]  =   min(abs(dv - search_limits(1))) ; 
[~,upper_index]  =   min(abs(dv - search_limits(2))) ; 
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
if(display_plots(1)) == 1
h_ = figure; 
plot(dv,mm33,"Color",'b') 
hold on
end

end

if(display_plots(1)) == 1
plot(dv(max_ind), max_val,'o','markersize', 10 );
title (['peak = ',num2str(dv(max_ind)*1000),'mm'])
end

end %function [max_ind), max_val]  = get_point_for_mode_map(mm33,dv)
