function Block_DATA = compile_data_block_auto_paul (threshold_values)

% compile_data_block_auto_paul ([0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1])
% this is a modification from original- compile_data_block_auto-  whch still exists
initial_thresh = 0.14 ;
window_start   = 0.55 ;
max_number_of_slices = 33;
plot_peak_find = 0;
% first time plot


% have a seperate  program that displays the mode map and the peak finding
% for a particular Block file-  dont do it in this one


%label_key  =  { 0 , 'zero' ; 1 , 'one' ; 2 , 'two' ; 3 ,'three'; 4 ,'four'; 5 ,'five'}; 
%  label_key  =  { 0 , 'zero' ; 1 , 'one' ; 2 , 'two' ; 3 ,'three'; 4 ,'four'};
% label_key  =  {0,'clear';1,'clear';2,'monitor';3,'monitor';4,'change'} ; 

% label_key  =  { 0,'clear'; 1,'clear'; 2,'monitor'; 3,'change'; 4,'change'; 5,'change' } ; 

%-----------------------------------------------------------------------
 label_key  =  {0,'clear';1,'clear';2,'clear';3,'monitor';4,'change'} ; 
% label_key  =  {0,'clear';1,'monitor';2,'monitor';3,'monitor';4,'change'} ; 
% label_key  =  {0,'clear';1,'clear';2,'monitor';3,'change';4,'change'} ; 
%-----------------------------------------------------------------------

Labels_ = label_key(:,2)' ;

% make the data block so that it -

P_W_D = pwd;
cd('P:\GITHUBS\AIDATA')
[chosen_files , path, ok_]  =  uigetfile('*.*','Select the INPUT DATA FILE(s)','MultiSelect','on');

if ok_
tag_label_index =  assign_labels(label_key,chosen_files); 
%  need to create  Get_single_test_values_paul  as mod of  -----  Get_single_test_values

for index = 1 : length(chosen_files)

disp(['File Name:  ', chosen_files{index},'(file no: ',num2str(index),').'])

for index_2 = 1:length(threshold_values)    
disp(['Threshold val: ' num2str(threshold_values(index_2))])

if index_2 == 1  &&  plot_peak_find ==1
do_plot = 1;
else
do_plot = 0;    
end %if index_2 == 1  &&  plot_peak_find ==1


[traces_dummy, Peak_loc{index}{index_2}, crack_mode_{index}{index_2}] =  Get_single_test_values_paul (chosen_files{index} , path , Labels_ , tag_label_index(index), threshold_values(index_2) , max_number_of_slices,initial_thresh,window_start,do_plot,index);


end %for index_2 = 1:length(threshold_values)    
traces{index} = traces_dummy;

end %for index = 1 : length(chosen_files)

% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
Block_DATA.File_labels       = Labels_                ; 
Block_DATA.crack_mode_       = crack_mode_            ;
Block_DATA.File_label_index  = tag_label_index        ; 
Block_DATA.Peak_loc          = Peak_loc               ;
Block_DATA.file_             = chosen_files           ;
Block_DATA.traces            = traces                 ;
Block_DATA.threshold_value   = threshold_values       ;
Block_DATA.max_number_of_slices= max_number_of_slices ;
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% this goes in the predict part

cd(P_W_D)

[Block_DATA.Labels_ , Block_DATA.tag_label_index, Block_DATA.conversion_key] = create_Unique_labels(Block_DATA.File_labels , Block_DATA.File_label_index);

if length(threshold_values) ==1
file_name = [path,'Block_data_',num2str(length(Labels_)) , '_Labs_',num2str(threshold_value*100),'_perc_thresh_', num2str(length(chosen_files)),'_tests'];
else
file_name = [path,'Block_data_',num2str(length(Labels_)) , '_Labs_',num2str(length(threshold_values)),'_threshVALS_', num2str(length(chosen_files)),'_tests'];
end %if length(threshold_values) ==1


no_files =length(dir([file_name,'*.mat']));

if no_files ==0
save([file_name,'.mat'],'Block_DATA')
else
save([file_name,'_',num2str(no_files+1),'.mat'],'Block_DATA')
end

else
cd(P_W_D) 
disp('bailed')

end



end %function compile_data_block(Percentage_of_peak, Labels_)

% ----------------------------------------------------------------

function [traces,Peak_locations,crack_mode_stack ] =  Get_single_test_values_paul (file_ , path_ , Labels_ , tag_label_index,threshold_value, max_number_of_slices,initial_thresh,window_start,do_plot,name_index)    


tag_label = Labels_{tag_label_index};

plot_options  = load_structure_from_file('plot_options_.dat');
dummy =  open(strcat(path_,file_));

if  isfield (dummy, 'rail_tester')==1

grid_data = fn_get_grid_data(dummy.rail_tester , plot_options);
mode_map = grid_data.data_stack;

mm33  = squeeze(mode_map(3,3,:))  ;
mm22  = squeeze(mode_map(2,2,:))  ;
dv          = grid_data.distance_vector    ;   
traces.mm33 = mm33   ;
traces.mm22 = mm22   ;
traces.dv   = dv     ; 

[Peak_indices]  =  get_points_for_mode_map_paul(mm33 , dv , threshold_value, max_number_of_slices,initial_thresh,window_start,do_plot,name_index);


Peak_locations.mod_val   = traces.dv(Peak_indices.mod_val  )           ;
Peak_locations.lower_val = traces.dv(Peak_indices.lower_val)           ;
Peak_locations.upper_val = traces.dv(Peak_indices.upper_val)           ;
Peak_locations.actual_peak = traces.dv(Peak_indices.actual_peak_val)   ;



[crack_mode_stack,~] = get_normalised_stack_and_mean(Peak_indices.lower_val,Peak_indices.upper_val,mode_map);

else
disp('no rail_tester field in structure - data is not in theprocessed format'  )  
crack_mode      = 'void' ;
tag_label_index = 'void' ;
end %if  isfield (dummy, 'rail_tester')==1

end %function [traces, Peak_loc, crack_mode_] =  Get_single_test_values_paul (file_ , path_ , Labels_ , tag_label_index ,display_plot);    


%--------------------------------------------------------------------------------------------------------------
function [Peak_indices]  =  get_points_for_mode_map_paul(mm33 , dv , thresh_val, num_slices,initial_thresh,window_start,do_plot,name_index)


start_val       =   min(find(dv>window_start)) + min(find(mm33(find(dv>window_start))  >   max(mm33(find(dv>window_start)))*initial_thresh))-1;

mm33_s = mm33(start_val:start_val+200);
mm33_s_diff = diff(mm33_s);
dum_ = find(mm33_s_diff > 0);

DV2 = dum_(find(diff(dum_)>1));
actual_peak_val = DV2(1)+ start_val;
actual_max_val = mm33(actual_peak_val);
target_val=  actual_max_val*thresh_val;
temp_val = actual_peak_val;

peak_found = 0;
while peak_found ==0
temp_val = temp_val -1;
if mm33(temp_val) <= target_val
   mod_val = temp_val;
   peak_found =1;
end    

end % while peak_not_found ==1

Peak_indices.mod_val          =   mod_val;
lower_val        =   Peak_indices.mod_val-floor(num_slices/2);
Peak_indices.lower_val        =   lower_val;
upper_val        =   Peak_indices.mod_val+floor(num_slices/2);
Peak_indices.upper_val        =   upper_val;
Peak_indices.actual_peak_val  =   actual_peak_val;

 % plot option in here  ---------------------------------
if do_plot ==1
figure
plot(dv,mm33)

hold on
%plot(dv(start_val),mm33(start_val),'g.','markersize',20)
%-------------------------------------------------------
plot(dv(actual_peak_val),mm33(actual_peak_val),'g.','markersize',10)
plot(dv(mod_val),mm33(mod_val),'rs','markersize',10)

plot(dv(lower_val),mm33(lower_val),'r.','markersize',10)
plot(dv(upper_val),mm33(upper_val),'r.','markersize',10)

xlim([0 round(max(dv))])
ylim([0 1.2*max( mm33(find(dv>0)))])
xlabel('Dist (m)')
ylabel('M33 Amplitude')
title(['Dist loc for mode map  (file no.',num2str(name_index),')'])    %  get the file name
ylim_s =  ylim;
xlim_s =  xlim;

plot([window_start window_start], [ylim_s(1) ylim_s(2)], 'r:')
plot([xlim_s(1) xlim_s(2)], [max(mm33(find(dv>window_start)))*initial_thresh max(mm33(find(dv>window_start)))*initial_thresh], 'b:')
legend('M33','Peak','Mode centre val', 'av start','av end','Xgate','Ygate')
end % if do_plot ==1

% plot option in here   ---------------------------------



end %function [max_ind_stack]  =  get_points_for_mode_map_paul(file_,mm33,dv,threshold_value,display_plot);


%--------------------------------------------------------------------------------------------------------------
function [MP_stack,MP_mean] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)

MP_stack = zeros(4,4,upper_val-lower_val);
count = 0;

for index = lower_val:upper_val
count = count + 1;
temp_MM =mode_map(:,:,index);

MP_stack(:,:,count) = temp_MM/mean(mean(temp_MM));
end  % for index = lower_val:upper_val

MP_mean = mean(MP_stack,3);
end %function [MP_stack,MP_mean] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)

%   -------------------------------------------------   
%   3/1   ---   2/4    ----  1/2    ------    4/4
%   ----------------Divide everything by 4/1
%  what we see
%  3/1 an 1/1  aty  the same-  normalise with this
% change themost  :  4/2--2/4   and  4/4  ---   
% ----------------------------------
% 2 values and normalise with 1/1  normoilse to 3/3 as this is the principle
% ----------------------------------



function tag_label_index =  assign_labels(label_key,chosen_files) 

for index = 1: length(chosen_files)

tag_label_index(index) = find([label_key{:,1}]== str2num(chosen_files{index}(find(chosen_files{index}=='H')+1)));

end %for index = 1: length(chosen_files)
end %function tag_label_index =  assign_labels(label_key,chosen_files) 

function text_ = remove_(text_)
text_(find(text_=='_')) =  ' ';
end %function text_  remove_(text_)


