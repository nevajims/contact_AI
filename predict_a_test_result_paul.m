function  output_ =  predict_a_test_result_paul(varargin)
nargin_ = nargin;

% nargin = 0 or 1   -   for manual use
% nargin = []  -   for auto use
% 
% for auto use -  
% passin the data block  
%
% (1)  path to the file
% (2)  Block_file_and_path
% (3)  mode_pairs_to_Use
% (4)  NumNeighbors
% (5)  Slice_index
% (6)  Thresh_index
% (7)

% SINGLE USE
% OP =  predict_a_test_result_paul('P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_5_Labs_12_threshVALS_25_tests.mat');

% MULTI USE
% OP =  predict_a_test_result_paul('P:\GITHUBS\AIDATA\107_2_new\Processed_data\PD_CW_test_Mark_Evans__H0CE107$1$_1.mat','P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_5_Labs_12_threshVALS_25_tests.mat',[1:16],3,6,5);

% (TOTAL_FILE_PATH,DATA_PATH,mode_pairs_to_Use,NumNeighbors,Slice_index,Thresh_index)
% 
plot_options        = load_structure_from_file('plot_options_.dat');

initial_thresh      = 0.2    ;
window_start        = 0.3    ; 

include_ai          = 1      ;
include_LL          = 1      ; 

labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4','mean of all'}; 
std_bar_size = 2;


%labels{mode_pairs_to_Use} 
%display_plots = [1,1,1];

display_plots = [0,0,0];

% diplay_txt =  [1,1,1,1,1,1,1,1,1,1];
% diplay_txt =  [1,0,1,0,1,1,0,0,0,0];
diplay_txt =  [0,0,0,0,0,0,0,0,0,0];

% diplay_txt =  [0,0,0,0,1,0,0,1,1,1];
% diplay_txt =  [1,1,1,1,1,1,1,1,1,1];

db_range = 1.6;
data_dir = 'P:\GITHUBS\AIDATA';
P_W_D = pwd;

% disp(['nargin = ', num2str(nargin_)])


if nargin_ == 0 ||  nargin_ == 1
      cd('P:\GITHUBS\AIDATA')
      [FILE_TO_PREDICT,file_path_] = uigetfile('*.mat',  'Selec the file to Predict','MultiSelect','off');
      cd (P_W_D)
mode_pairs_to_Use   = 1:16   ;
NumNeighbors        = 3      ;
end %if nargin == 0 ||  nargin == 1
      
switch (nargin_)
    case(0)
     cd('P:\GITHUBS\AIDATA')
     [file_,path_] = uigetfile('*.mat',  'Select BLOCK File','MultiSelect','off');
     DATA_PATH  = [path_,file_];
     cd(P_W_D)

    case(1) 
     DATA_PATH             = varargin{1};
    
    case (6) 

 
     TOTAL_FILE_PATH   = varargin{1};
     FILE_TO_PREDICT = TOTAL_FILE_PATH(max(strfind(TOTAL_FILE_PATH,'\'))+1:end);
     file_path_      = TOTAL_FILE_PATH(1:max(strfind(TOTAL_FILE_PATH,'\')));
     
     DATA_PATH         = varargin{2};
     mode_pairs_to_Use = varargin{3};
     NumNeighbors      = varargin{4};
     Slice_index       = varargin{5};
     Thresh_index      = varargin{6};
end % if nargin == 0 

dummy = open(DATA_PATH);
Block_DATA = dummy.Block_DATA;
block_file_ = DATA_PATH(max(strfind(DATA_PATH,'\'))+1:end);

[slice_options,slice_indices] = get_slice_options(Block_DATA.max_number_of_slices);

if nargin_ == 0 ||  nargin_ == 1

choices_1= arrayfun(@(a)num2str(a),slice_options,'uni',0) ;
[Slice_index,~] = listdlg('PromptString','Choose Number of averages (slices)', 'ListString',choices_1,'SelectionMode','single' );


choices_2 = arrayfun(@(a)num2str(a),Block_DATA.threshold_value,'uni',0) ;
[Thresh_index,~] = listdlg('PromptString','Choose Threshold Value', 'ListString',choices_2,'SelectionMode','single' );


end %if nargin == 0 ||  nargin == 1

Thresh_val_ = Block_DATA.threshold_value(Thresh_index);
no_slices = slice_options(Slice_index);

%disp(['Slice index: ',num2str(Slice_index) ])
%disp(['Thresh_index: ',num2str(Thresh_index) ])
% slice_indices{Slice_index}


dummy_1              = load([file_path_,FILE_TO_PREDICT]);
grid_data            = fn_get_grid_data(dummy_1.rail_tester , plot_options);

mode_map             = grid_data.data_stack               ;
mm33                 = squeeze(mode_map(3,3,:))           ;
dv                   = grid_data.distance_vector          ;  
Traces.mm33          = squeeze(mode_map(3,3,:))     ;
Traces.mm22          = squeeze(mode_map(2,2,:))     ;
Traces.mm44          = squeeze(mode_map(4,4,:))     ;
Traces.mm42          = squeeze(mode_map(4,2,:))     ;
Traces.mm24          = squeeze(mode_map(2,4,:))     ;
Traces.mm31          = squeeze(mode_map(3,1,:))     ;
Traces.mm13          = squeeze(mode_map(1,3,:))     ;

output_.grid_data  = grid_data; 
output_.chan_data =  dummy_1.test_data.raw_data;

[mod_val , lower_val , upper_val , actual_peak_val]  =  get_peak_values(dv , mm33 , initial_thresh , Thresh_val_ , no_slices, window_start);



% [MP_stack,MP_mean] =  get_normalised_stack_and_mean_P(lower_val,upper_val,mode_map);

[ ~ , MP_mean ] =  get_normalised_stack_and_mean_P(lower_val,upper_val,mode_map);


% now compile the learning data and make the prediction

crack_mode_matrix = create_crack_mode_matrix(Block_DATA.crack_mode_ , Thresh_index, slice_indices{Slice_index});

if include_ai == 1
AI_Block  = Create_AI_learning_Block(NumNeighbors,mode_pairs_to_Use, crack_mode_matrix  ,  Block_DATA.Labels_ , Block_DATA.tag_label_index );
end %if include_ai == 1


SV_crack_mode = MP_mean;  %SV = speciic value
spec_vals_temp = reshape(SV_crack_mode, 1 , numel(SV_crack_mode));


if include_ai == 1
[return_tag,~,~] = predict(AI_Block , spec_vals_temp(mode_pairs_to_Use));
end % if include_ai == 1

for index = 1:length(Block_DATA.Labels_)
%disp(['Tag = ',Labels_{index} ,'.'])
tag_indicies                   = find(Block_DATA.tag_label_index == index);
tag_modes_ =   crack_mode_matrix(:,:,tag_indicies);
mean_temp = mean(tag_modes_ , 3) ;
mean_tag_modes_{index}         = mean_temp;
std_temp = std(tag_modes_,0,3)  ;
std_tag_modes_{index}          = std_temp;
end %for index = 1:length(Labels_)

Block_DATA.mean_tag_modes_ = mean_tag_modes_;
Block_DATA.std_tag_modes_  = std_tag_modes_;

[Score_vals,plot_data{2}]   = do_mean_std_plot(spec_vals_temp ,Block_DATA,mode_pairs_to_Use, labels ,std_bar_size,display_plots,FILE_TO_PREDICT,block_file_);

[score_table,log_lik_table, ~, ~ , std_dist_table, predict_tag , LL_tag]    =    get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_,std_bar_size,include_LL);




% score_table =  dist from mean
% predict_tag  = dist from mean 


file_label = FILE_TO_PREDICT(find(FILE_TO_PREDICT =='H')+1);

output_.file_label = file_label;
output_.txt{1}='-----------------------------------------------------------------\n'                   ; 
output_.txt{1}= [output_.txt{1},FILE_TO_PREDICT,'\n']                                                        ;
output_.txt{1}= [output_.txt{1},'LABEL: ',file_label,'\n']                                             ;
output_.txt{1}= [output_.txt{1},'-----------------------------------------------------------------\n'] ;

if diplay_txt(1) ==1
fprintf(output_.txt{1})
end %if diplay_txt(1) ==1


output_.txt{2}= ['Threshold choice is: ', num2str(Thresh_val_),'.\n']                   ;
output_.txt{2}= [output_.txt{2},'The number of slices of average: ',num2str(no_slices),'.\n']          ;
output_.txt{2}= [output_.txt{2},'Block file used: ', block_file_ ,'.\n']          ;
output_.txt{2}= [output_.txt{2},'#mode pairs used: ', num2str(length(mode_pairs_to_Use)),'.\n']          ;
output_.txt{2}= [output_.txt{2},'-----------------------------------------------------------------\n'] ;


if diplay_txt(2) ==1
fprintf(output_.txt{2})
end %if diplay_txt(1) ==1

output_.PL = num2str(1000*dv(actual_peak_val)) ;

output_.txt{3}= ['Peak location: ',num2str(1000*dv(actual_peak_val)),' mm.\n'];
output_.txt{3}= [output_.txt{3},'-----------------------------------------------------------------\n'] ;

if diplay_txt(3) ==1
fprintf(output_.txt{3})
end

output_.txt{4} = display_Block_data_stats(Block_DATA);
output_.txt{4}= [output_.txt{4},'-----------------------------------------------------------------\n'] ;

if diplay_txt(4) ==1
fprintf(output_.txt{4})
end

if include_ai == 1
output_.txt{5} = ['The AI predicts that this results is:   ', return_tag{1} ,' .\n'];
output_.predict{1} = return_tag{1} ; 
else
output_.txt{5} = 'The AI prediction currently removed \n';
output_.predict{1} = NaN; 
end %if include_ai == 1

if diplay_txt(5) ==1
fprintf(output_.txt{5})
end

if include_LL ==1
output_.txt{6} = ['The dist from mean predicts that the result is:   ',  predict_tag ,' .\n'];
output_.txt{6} = [output_.txt{6},'The log likelyhood predicts that the result is:   ',  LL_tag ,' .\n'   ];
output_.txt{6}= [output_.txt{6},'-----------------------------------------------------------------\n'] ;

output_.predict{2} = predict_tag ; 
output_.predict{3} = LL_tag ; 

else
output_.txt{6} = ['The dist from mean predicts that the result is:   ',  predict_tag ,' .\n'];
output_.txt{6} = [output_.txt{6},'The LL prediction currently removed \n'];
output_.predict{2} = predict_tag ; 
output_.predict{3} = NaN ; 
end
if diplay_txt(6) ==1
fprintf(output_.txt{6})
end

output_.txt{7} = '-----------------------------------------------------------------\n';
output_.txt{7} = [output_.txt{7}, 'Distance from mean\n'];
output_.txt{7} = [output_.txt{7}, '-----------------------------------------------------------------\n'];
output_.txt{7} = [output_.txt{7}, 'Dist from mean for each mode pair\n'];
output_.score_table = score_table;


TString = evalc('disp(output_.score_table)');
TString = remove_strong(TString);
output_.txt{7} = [output_.txt{7}, '-----------------------------------------------------------------\n'];
output_.txt{7} = [output_.txt{7}, TString,                                                         '\n'];
output_.txt{7} = [output_.txt{7}, '-----------------------------------------------------------------\n'];

if diplay_txt(7) ==1
fprintf(output_.txt{7})
end


if include_LL ==1
output_.txt{8} = '-----------------------------------------------------------------\n';
output_.txt{8} = [output_.txt{8}, 'Log Likelyhood\n'];
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];

output_.log_lik_table = log_lik_table;

TString = evalc('disp(output_.log_lik_table)');
TString = remove_strong(TString);
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];
output_.txt{8} = [output_.txt{8}, TString,                                                         '\n'];
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];
else
output_.txt{8} = '-----------------------------------------------------------------\n';
output_.txt{8} = [output_.txt{7},output_.txt{7}, 'The Log Likelyhood table is not included\n'];
output_.txt{8} = [output_.txt{7},'-----------------------------------------------------------------\n'];
end

if diplay_txt(8) ==1
fprintf(output_.txt{8})
end

output_.txt{9} = '-----------------------------------------------------------------\n';
output_.txt{9} = [output_.txt{9}, 'No. of STD dist from mean\n'];
output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];
output_.std_dist_table = std_dist_table;

TString = evalc('disp(output_.std_dist_table)');
TString = remove_strong(TString);

output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];
output_.txt{9} = [output_.txt{9}, TString,                                                         '\n'];
output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];

if diplay_txt(9) ==1
fprintf(output_.txt{9})
end

%Now the plots

plot_data{1} =  plot_mode_sp(FILE_TO_PREDICT,dv,mm33,mod_val,lower_val,upper_val,actual_peak_val,display_plots(1));


plot_data{3} =  get_interp_data(SV_crack_mode,50);

if display_plots(3) ==1
plot_interp_data(plot_data{3},FILE_TO_PREDICT,db_range)
end %if display_plots(3) ==1


output_.plot_data = plot_data;
end % function predict_a_test_result_paul(varargin)

%---------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------

% output_.plot_data{1} 

%----------------------------------------------------------------------
function  PD =  plot_mode_sp(file_,dv,mm33,mod_val,lower_val,upper_val,actual_peak_val,do_plot)

PD.file_ = file_; PD.dv    = dv; PD.mm33  = mm33; PD.mod_val = mod_val ; PD.lower_val = lower_val ; PD.upper_val = upper_val ; PD.actual_peak_val = actual_peak_val;

if do_plot == 1
figure
plot(dv,mm33)
hold on
plot(dv(mod_val),mm33(mod_val),'g.','MarkerSize',25)
plot(dv(lower_val),mm33(lower_val),'r.','MarkerSize',10)
plot(dv(upper_val),mm33(upper_val),'r.','MarkerSize',10)
plot(dv(actual_peak_val),mm33(actual_peak_val),'k.','MarkerSize',20)
title(remove_( file_)) 
end %if do_plot == 1

end % function plot_mode_selection_point(file_,dv,mm33,mod_val,lower_val,upper_val)
%----------------------------------------------------------------------

function crack_mode_matrix = create_crack_mode_matrix (crack_mode_,Thresh_index, slice_ind)

crack_mode_matrix = zeros(4,4,length(crack_mode_));

for index = 1:length(crack_mode_)
dum = crack_mode_{index}{Thresh_index}(:,:,slice_ind);
crack_mode_matrix(:,:,index) = mean(dum,3);
end %for index = 1:length(crack_mode_)

%for index = 1:length(crack_mode_)
%dummy =  crack_mode_{index}{PP_index};    
%norm_crack_mode_(:,:,index) = dummy / dummy(normalising_mode_pair(1),normalising_mode_pair(2));
%end %for index = 1:length(crack_mode_)

end %function crack_mode_matrix = create_crack_mode_matrix(Block_DATA.crack_mode_,Thresh_index, slice_indices);

function [mod_val  , lower_val  ,  upper_val  ,  actual_peak_val]  =  get_peak_values(dv,mm33,initial_thresh,thresh_val,num_slices, window_start )

start_val       =   min(find(dv>window_start)) + min(find(mm33(find(dv>window_start))  >   max(mm33(find(dv>window_start)))*initial_thresh))-1;

mm33_s = mm33(start_val:start_val+200);
mm33_s_diff = diff(mm33_s);
dum_ = find(mm33_s_diff>0);
DV2 = dum_(find(diff(dum_)>1));
actual_peak_val = DV2(1)+ start_val;
actual_max_val = mm33(actual_peak_val);
target_val=  actual_max_val*thresh_val;

temp_val = actual_peak_val;
peak_found =0;
while peak_found ==0
temp_val = temp_val -1;
if mm33(temp_val) <= target_val
   mod_val = temp_val;
   peak_found =1;
end    

end % while peak_not_found ==1
lower_val     =   mod_val-floor(num_slices/2);
upper_val     =   mod_val+floor(num_slices/2);

do_plot = 0;

if do_plot ==1
plot(dv,mm33)
hold on
plot(dv(start_val),mm33(start_val),'g.','markersize',20)
plot(dv(actual_peak_val),mm33(actual_peak_val),'g.','markersize',20)

plot(dv(mod_val),mm33(mod_val),'r.','markersize',30)
plot(dv(lower_val),mm33(lower_val),'r.','markersize',10)
plot(dv(upper_val),mm33(upper_val),'r.','markersize',10)
end % if do_plot ==1

end % function [mod_val  , lower_val  ,  upper_val  ,  actual_peak_val]  =  get_peak_values(dv,mm33,initial_thresh,thresh_val,num_slices)

function [slice_options ,  slice_indices] = get_slice_options(max_number_of_slices)
slice_options = [1:2:max_number_of_slices];
central_val = ceil(max_number_of_slices/2);
for index = 1: length(slice_options)
amount_to_PM = floor(slice_options(index)/2);
slice_indices{index} =  [(central_val-amount_to_PM): (central_val+amount_to_PM)];
end %for index = 1: length(slice_options)
%slice_indices
end %function slice_options = get_slice_options(Block_DATA.max_number_of_slices);

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

function plot_MM_single( db_range , MP_mean_vals,sub_plot)
subplot(sub_plot)

mode_PLOT_data_temp  =  get_interp_data(MP_mean_vals,50);
colormap default;
surf(mode_PLOT_data_temp);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
colorbar;
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

end %function figH=  plot_MM_single( db_range , MP_mean_vals)

function figH=  plot_MM_data(file_ , plot_title , db_range , sub_plots_inds, MP_mean_vals)

figH = figure;

for index = 1: length(file_) 

MP_mean_temp = MP_mean_vals(:,:,index);

mode_PLOT_data_temp  =  get_interp_data(MP_mean_temp,50);

subplot(sub_plots_inds(length(file_),1),sub_plots_inds(length(file_),2),index)
colormap default;
surf(mode_PLOT_data_temp);
view(2);
axis equal;
shading flat;
axis off;
caxis([0, db_range]);
colorbar;

% title([file_{index}])


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
end %for index = 1: length(file_)

%sgtitle(plot_title) 


end %function plot_interp_data(interp_data,title_,db_range)

function  figH=  plot_mode_selection_point(file_,dv,mm33,mod_val,lower_val,upper_val,plot_title , sub_plots_inds)
figH = figure;


for index = 1: length(file_) 
subplot(sub_plots_inds(length(file_),1),sub_plots_inds(length(file_),2),index)
plot(dv{index},mm33{index})
hold on
plot(dv{index}(mod_val(index)),mm33{index}(mod_val(index)),'g.','MarkerSize',25)

plot(dv{index}(lower_val(index)),mm33{index}(lower_val(index)),'r.','MarkerSize',10)
plot(dv{index}(upper_val(index)),mm33{index}(upper_val(index)),'r.','MarkerSize',10)

%title([file_{index}, ' Pos: ',num2str(dv{index}(mod_val(index)))])

end % for index = 1: length(file_)

sgtitle(plot_title) 

end % function plot_mode_selection_point(file_,dv,mm33,mod_val,lower_val,upper_val)

function [MP_stack,MP_mean] = get_normalised_stack_and_mean_P(lower_val,upper_val,mode_map)
MP_stack = zeros(4,4,upper_val-lower_val);
count = 0;
for index = lower_val:upper_val
count = count + 1;
temp_MM =mode_map(:,:,index);
MP_stack(:,:,count) = temp_MM/mean(mean(temp_MM));
end  % for index = lower_val:upper_val
MP_mean = mean(MP_stack,3);
end %function [MP_stack,MP_mean] = get_normalised_stack_and_mean(lower_val,upper_val,mode_map)



