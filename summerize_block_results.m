function summerize_block_results(varargin)
%function summerize_block_results(combined_data)

%  3 options:
% ---------------------------------------------------
% (1) No args:   select a combined_data file to open 
% (2) a  1 arg -   path of data file  
%     e.g
%     summerize_block_results('P:\GITHUBS\AIDATA\new_CLAMP_2\Processed_data\Block_data_6_L24_DV_65_9 _6GR.mat')
 
% (2) b  1 arg -   data file passed in (combined_data) as output from :::: combined_data   =  predict_multiple_tests(varargin) 
% ---------------------------------------------------

input_ok = 1;

switch(nargin)
    case(0)
% select the file
P_W_D = pwd ;
cd('P:\GITHUBS\AIDATA')
[file_,path_]=uigetfile('COMB_DATA*.mat');
Comb_data_file = [path_,file_];
dummy =  open(Comb_data_file);
combined_data = dummy.combined_data;
cd(P_W_D)
    case(1)

if isstruct(varargin{1})
combined_data = varargin{1};
Comb_data_file = 'NOT FROM FILE';

input_ok = 1;
elseif isstr(varargin{1}) 
    
if isfile(varargin{1})
dummy =  open(varargin{1});
combined_data = dummy.combined_data;
input_ok = 1;
end %if isfile(varargin{1})

else
input_ok = 0;
end %if isstruct(varargin{1})


end %switch(nargin)

if isfield(combined_data,'summary_results') && isfield(combined_data,'overall_settings')
%do nothing
else
input_ok = 0;
disp('combined data doesnt have the correct fields')
end    








if input_ok  ==1

overall_settings =  combined_data.overall_settings ;
summary_results  =  combined_data.summary_results  ; 
disp(['Combined data file used:',Comb_data_file,'.']);


% plot_options = load_structure_from_file('P:\GITHUBS\contact_AI\plot_options_.dat');
fprintf(overall_settings.txt{1})

FL_s = zeros(1,length(summary_results));

for index = 1 : length(summary_results)
FL_s(index) =  str2num(summary_results{index}.file_label) ; 
end     %   for index = 1 : length(summary_results)


Unique_FLs = unique (FL_s,'stable' );
U_tags = unique(overall_settings.File_labels,'stable');
mode_pair_labels =   {overall_settings. labels{overall_settings.mode_pairs_to_Use}};

mode_pair_labels_ff = make_field_freindly(mode_pair_labels);


for index = 1: length (Unique_FLs) 
% step through each tag category

type_indices  =  find(FL_s == Unique_FLs(index));

disp('--------------------------------------------')
disp('--------------------------------------------')
disp(['File Label number ',num2str(Unique_FLs(index)) ]) 
disp(['File Label ::: ',overall_settings.File_labels{Unique_FLs(index)+1}]) 
disp('--------------------------------------------')
disp('--------------------------------------------')

exp_tag = overall_settings.File_labels{Unique_FLs(index)+1};
temp_count = 0;
SR_temp = [];
temp_tests = [];
temp_AI = [];
temp_DistM = [];
temp_LeastL = [];
temp_MP_DistM_preds = [];
temp_MP_LL_preds    = []; 
temp_sym_12_21  = [];
temp_sym_13_31 = [];
temp_sym_14_41 = [];
temp_sym_23_32 = [];
temp_sym_24_42 = [];
temp_sym_34_43 = [];
temp_sym_max = [];
temp_mod_12 = [];
temp_mod_13 = [];
temp_mod_14 = [];
temp_mod_23 = [];
temp_mod_24 = [];
temp_mod_34 = [];
temp_mod_max= [];
temp_mod_min= [];



for index_2 = 1: length(type_indices)
% step through the number of tests in each tag
%disp(num2str(index_2))
temp_count = temp_count + 1;
%type_indices(index_2);

[sym_vals_temp, sym_max_ ] = get_mode_symmetry_vals(summary_results{type_indices(index_2)}.crack_mode_vals);

[mode_vals_temp, mode_vals_max_, mode_vals_min_ ] = get_mode_vals(summary_results{type_indices(index_2)}.crack_mode_vals);




SR_temp{temp_count} =  summary_results{type_indices(index_2)};



%sym_vals = [md_vals(1,2)/md_vals(2,1) , md_vals(1,3)/md_vals(3,1), md_vals(1,4)/md_vals(4,1),...
%            md_vals(2,3)/md_vals(3,2) ,md_vals(2,4)/md_vals(4,2) , md_vals(3,4)/md_vals(4,3)];



temp_tests{index_2} = [summary_results{type_indices(index_2)}.file_name(find(summary_results{type_indices(index_2)}.file_name=='H'):end-4) ];     
temp_AI{index_2}       = summary_results{type_indices(index_2)}.predict{1}   ;
temp_DistM{index_2}    = summary_results{type_indices(index_2)}.predict{2}   ;
temp_LeastL{index_2}   = summary_results{type_indices(index_2)}.predict{3}   ;
temp_MP_DistM_preds(index_2,:) = get_predictions_from_table(summary_results{type_indices(index_2)}.score_table)             ;
temp_MP_LL_preds(index_2,:)    = get_predictions_from_table(summary_results{type_indices(index_2)}.log_lik_table)           ;

temp_sym_12_21 {index_2} = sym_vals_temp(1) ; 
temp_sym_13_31 {index_2} = sym_vals_temp(2) ;
temp_sym_14_41 {index_2} = sym_vals_temp(3) ; 
temp_sym_23_32 {index_2} = sym_vals_temp(4) ;
temp_sym_24_42 {index_2} = sym_vals_temp(5) ;
temp_sym_34_43 {index_2} = sym_vals_temp(6) ;
temp_sym_max   {index_2}  = sym_max_        ; 

temp_mod_12 {index_2} = mode_vals_temp(1) ;
temp_mod_13 {index_2} = mode_vals_temp(2) ; 
temp_mod_14 {index_2} = mode_vals_temp(3) ;
temp_mod_23 {index_2} = mode_vals_temp(4) ;
temp_mod_24 {index_2} = mode_vals_temp(5) ;
temp_mod_34 {index_2} = mode_vals_temp(6) ;
temp_mod_max{index_2} = mode_vals_max_    ; 
temp_mod_min{index_2} = mode_vals_min_    ; 


end %for index_2 = 1: length(type_indices)

Sym_tab{index}.Test        = temp_tests'     ;
Sym_tab{index}.sym_12_21   = temp_sym_12_21' ;
Sym_tab{index}.sym_13_31   = temp_sym_13_31' ;
Sym_tab{index}.sym_14_41   = temp_sym_14_41' ;
Sym_tab{index}.sym_23_32   = temp_sym_23_32' ;
Sym_tab{index}.sym_24_42   = temp_sym_24_42' ;
Sym_tab{index}.sym_34_43   = temp_sym_34_43' ;
Sym_tab{index}.MAX         = temp_sym_max'   ;

mode_val_tab{index}.Test      =  temp_tests'   ;
mode_val_tab{index}.sym_12_21 =  temp_mod_12'  ;
mode_val_tab{index}.sym_13_31 =  temp_mod_13'  ;
mode_val_tab{index}.sym_14_41 =  temp_mod_14'  ;
mode_val_tab{index}.sym_23_32 =  temp_mod_23'  ;
mode_val_tab{index}.sym_24_42 =  temp_mod_24'  ;
mode_val_tab{index}.sym_34_43 =  temp_mod_34'  ;
mode_val_tab{index}.MAX       =  temp_mod_max' ; 
mode_val_tab{index}.MIN       =  temp_mod_min' ; 


temp_tests{index_2+1} = 'SCORE';
% now function for the score
temp_AI{index_2+1    }  = get_tag_score_(temp_AI      , exp_tag , U_tags)  ;
temp_DistM{index_2+1 }  = get_tag_score_(temp_DistM   , exp_tag , U_tags)  ;
temp_LeastL{index_2+1}  = get_tag_score_(temp_LeastL  , exp_tag , U_tags)  ;


Sum_tab{index}.Test   = temp_tests'      ;
Sum_tab{index}.AI     = temp_AI'         ;
Sum_tab{index}.DistM  = temp_DistM'      ;
Sum_tab{index}.LeastL = temp_LeastL'     ;

Tab_{index} =   struct2table(Sum_tab{index});

DistM_tab{index}.Test =  temp_tests'  ; 
LL_tab{index}.Test =  temp_tests'     ; 

for index_3 = 1: length(mode_pair_labels_ff)
dummy_  = U_tags(temp_MP_DistM_preds(:,index_3))';
dummy_{end+1} = get_tag_score_(dummy_,exp_tag , U_tags);
eval(['DistM_tab{index}.',mode_pair_labels_ff{index_3},'=dummy_;']);

dummy_2 = U_tags(temp_MP_LL_preds(:,index_3))';
dummy_2{end+1} = get_tag_score_(dummy_2,exp_tag , U_tags);

eval(['LL_tab{index}.',mode_pair_labels_ff{index_3},'=dummy_2;']);
end %for index_3 = 1: length(mode_pair_labels)



DistM = struct2table(DistM_tab{index})    ;
LL    = struct2table(LL_tab{index})       ;
SYM    = struct2table(Sym_tab{index})       ;
MV =    struct2table(mode_val_tab{index}) ;

disp(Tab_{index})
disp('--------------------------------------------')
disp('Distance from mean mode pairs')
disp('--------------------------------------------')
disp(DistM)
disp('--------------------------------------------')
disp('Log Likelyhood mode pairs')
disp('--------------------------------------------')
disp(LL)
disp('--------------------------------------------')
disp('mode symmetry')
disp('--------------------------------------------')
disp(SYM)
disp('--------------------------------------------')
disp('mode values')
disp('--------------------------------------------')
disp(MV)


do_mode_plots(SR_temp,['Label : ',overall_settings.File_labels{Unique_FLs(index)+1}]);

do_peak_plots(SR_temp,['Label : ',overall_settings.File_labels{Unique_FLs(index)+1}])

do_stat_plots(SR_temp,['Label : ',overall_settings.File_labels{Unique_FLs(index)+1}])




end %for index = 1: length (Unique_FLs) 

else
disp('Problem input argument- Bailing' )
end% if input_ok  ==1


end       %function summerize_block_results(overall_settings,summary_results)


function score_ = get_tag_score_(tags_,expected_tag,tag_types)
no_correct = 0;
no_one_out = 0;

for index = 1:length(tag_types)
if strcmp(expected_tag,tag_types{index})
expected_index = index;
end %if strcmp(expected_tag,tag_types{index})
end %for index 


for index = 1 : length(tags_) 
if strcmp(tags_{index},expected_tag)
no_correct = no_correct + 1;
else

for index_2 = 1:length(tag_types)
if strcmp(tags_{index},tag_types{index_2})
tag_index = index_2;   
end %if strcmp(tags_{index},tag_types{index_2})
end %for index_2 = 1:length(tag_types)
if abs(tag_index-expected_index) ==1
no_one_out = no_one_out+1;
end
end %if strcmp(tags_{index},expected_tag)
end % for index = 1 : length(tags_) 
 score_ =[num2str( round(1000* no_correct/length(tags_))/10),'/',num2str(round(1000* (no_correct+no_one_out)/length(tags_))/10)];
end %

function  Prediction_ =  get_predictions_from_table(table_)
tab_data  = table2array(table_)            ;
Row_names = table_.Properties.RowNames     ;

for index = 1:size(tab_data,2)-1
[~ , temp_tag] = min(tab_data(:,index))    ;   
Prediction_(index) = temp_tag;
end %for index = 1:size(tab_data,2)-1


end %function  prediction_ =  get_predictions_from_table


function  mode_pair_labels_ff = make_field_freindly(mode_pair_labels)

for index = 1: length(mode_pair_labels)
temp_ = mode_pair_labels{index};
temp_(find(temp_==' ')) = '';
temp_(find(temp_=='-')) = '_';
temp_= ['MP_',temp_];
mode_pair_labels_ff{index} = temp_;
end %for index = 1: length(mode_pair_labels)
end %function  mode_pair_labels_ff = make_field_freindly(mode_pair_labels)




% either
% ***** DONE ****   1/ overal score for the three (collated) prediction methods
% ***** DONE ****   2/ incorparate all the mode pairs in the table 
% ***** DONE ****   3/ overal score for the for each mode pair (dist from mean and LL)
% ***** DONE ****   4/ plot the mode maps in a collage  (max 9 plots / figure)  min one figure
% ***** DONE ****    per 'group'
% ***** DONE ****  5/ do the stat plot in a collage 
% ***** DONE ****  Mode symmetry score
%  parameters that dont vary much-  no change in those paramenters
%  check this :: 
%  LL  is it the lowest or the highest value-  appers to e thelowest but
%  should be the highest?

%---------------------------------------------------------
% ***** DONE ****  save the  4x 4 original data as the RAW matrix    %%%%%
%---------------------------------------------------------


