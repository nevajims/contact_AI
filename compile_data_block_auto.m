function Block_DATA = compile_data_block_auto (search_limits )

% Block_DATA = compile_data_block_auto ([0.65,0.9]);
%do_plot = 0;
% search_limits  =  [0.65,0.8];
Percentage_Peaks = [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100];

%label_key  =  {0,'green';1,'green';2,'amber';3,'amber';4,'red';5,'red'} ; 

%label_key  =  {0,'green';1,'green';2,'green';3,'amber';4,'amber';5,'red'} ; 


%label_key  =  {0,'clear';1,'clear';2,'monitor';3,'monitor';4,'monitor';5,'change'} ; 

label_key  =  { 0 , 'zero' ; 1 , 'one' ; 2 , 'two' ; 3 ,'three'; 4 ,'four'; 5 ,'five'}; 

%label_key  =  {0,'no crack';1,'no crack';2,'small crack';3,'small crack';4,'Large crack';5,'Large crack'} ; 
Labels_ = label_key(:,2)';

% function Block_DATA = compile_data_block_auto (Percentage_Peak, Labels_)
% make the data block so that it -

% ---- DONE  (1)  sets the tags automatically  ---    put the mapping into the start  of the program

%  (2)  sets the search limits automatically
%  (3)  does the rangeof %%  from  0 -- 100;
%  (4)  let it plot mode maps/ search limits   for all / some / none of the
%   percentage peaks
%  add some  mode pair ratios (42+24)/22   and   symetries  (42/24)  

% Peak methods
%  1  --  peak in a selected window  
%  2  --  peak as a point
%  3  --  peak in a selected  window the get the percentage
%  4  --  peak in a pre defined window then get the percentage

P_W_D = pwd;
cd('P:\GITHUBS\AIDATA')
[chosen_files , path]  =  uigetfile('*.*','Select the INPUT DATA FILE(s)','MultiSelect','on');
tag_label_index =  assign_labels(label_key,chosen_files); 


%  display the search limits -  have an input that displays the search
%  limits once per file (for the first % peak option 

for index = 1 : length(chosen_files)
for index_2 = 1:length(Percentage_Peaks)
    if index_2 == length(Percentage_Peaks)/2
    
 %   if do_plot ==1
    display_plot = 1;
    file_{index} = chosen_files{index};
 %   end %if do_plot ==1
    
    
    else
    display_plot = 0;
    end %if index_2 == length(Percentage_Peaks)
    
    [traces{index}{index_2}, Peak_loc(index,index_2), crack_mode_{index}{index_2} ] =  Get_single_test_values ( Percentage_Peaks(index_2) , chosen_files{index} , path , Labels_,tag_label_index(index), search_limits,display_plot);    
    
    


end %for index_2 = 1:length(Percentage_Peaks)
end %for index = 1 : length(chosen_files)

% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
Block_DATA.File_labels           = Labels_              ; 

Block_DATA.crack_mode_       = crack_mode_          ;
Block_DATA.File_label_index   = tag_label_index      ; 

Block_DATA.Peak_loc          = Peak_loc             ;
Block_DATA.file_             = file_                ;
Block_DATA.traces            = traces               ;
Block_DATA.Percentage_Peaks   = Percentage_Peaks    ;
Block_DATA.search_limits     = search_limits        ; 

% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% ----------------------------------------------------------------------------------------------------------------------------------------------------------------%
% this goes in the predict part

cd(P_W_D)

[Block_DATA.Labels_ , Block_DATA.tag_label_index] = create_Unique_labels(Block_DATA.File_labels , Block_DATA.File_label_index);

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
save([path,'Block_data_',num2str(length(Labels_)) , '_L', num2str(length(chosen_files)),'_DV.mat'],'Block_DATA')

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


function [traces,Peak_loc,crack_mode ] =  Get_single_test_values ( Percentage_Peak,file_,path_,Labels_,tag_label_index, search_limits,display_plot)

if display_plot == 1
disp(['File Name:  ', file_])
end %if display_plot == 1


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


[max_ind]  = get_point_for_mode_map(file_,mm33,dv,Percentage_Peak,search_limits,display_plot);


%figure(h_)
%plot(dv(max_ind), max_val,'o','markersize', 10 );
%title ([tag_label,', peak = ',num2str(dv(max_ind)*1000),'mm'])


%  dont plot 
% fn_plot_grid_data(grid_data, plot_options ,dv(max_ind))


crack_mode = grid_data.data_stack(:,:,max_ind);
Peak_loc        =  dv(max_ind)*1000        ;


else
disp('no rail_tester field in structure - data is not in theprocessed format'  )  
Values_         =  0     ;
crack_mode      = 'void' ;
tag_label_index = 'void' ;
end %if  isfield (dummy, 'rail_tester')==1

end    % function [mode_values   ] =  Get_mode_values_from_a_test ()

%--------------------------------------------------------------------------------------------------------------


function [max_ind]  = get_point_for_mode_map(file_,mm33,dv, Percentage_Peak,search_limits , display_plot)

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

if display_plot == 1
h_ = figure; 
plot(dv,mm33,"Color",'b') 
hold on
plot( [dv(lower_index),dv(lower_index)],[min(mm33),max(mm33)  ],'r')
plot( [dv(upper_index),dv(upper_index)],[min(mm33),max(mm33)  ],'r')
plot(dv(max_ind), max_val,'o','markersize', 10 );
title ([remove_(file_) ,':  peak = ',num2str(dv(max_ind)*1000),'mm'])
end %if display_plot == 1

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

function tag_label_index =  assign_labels(label_key,chosen_files) 

for index = 1: length(chosen_files)
tag_label_index(index) = find([label_key{:,1}]== str2num(chosen_files{index}(find(chosen_files{index}=='H')+1)));
end %for index = 1: length(chosen_files)
end %function tag_label_index =  assign_labels(label_key,chosen_files) 





function text_ = remove_(text_)
text_(find(text_=='_')) =  ' ';
end %function text_  remove_(text_)


