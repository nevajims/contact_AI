function compiled_data =   predict_multiple_paul(mode_pairs_to_Use)

%compiled_data =   predict_multiple_paul([2,5,8,14]);

%compiled_data = NaN;
%compiled_data.settings_
% compile all the data to produce :::
% GRAPHS
% (1) mode maps 

% (2) location of peak 
% (3) priniple plots  
% (4) statistical plot   

% DATA QUALITY TABLES
% (1)
% (2)
% (3)
% (4)

% PREDICTION Values
% (1) overall predictions divided by group 
% (2) individual mode predictions   
% (3) 
% (4)

%PREDICTION tables 

% PREDICTIOn PERFORMANCE
% (1)
% (2)
% (3)

% divide tables and plots into different types H values ------ 

%  From old :::   
% everything from the  'compile_test_results_paul.mat'
% predict_multiple_paul(mode_pairs_to_Use)

%  -----   Disp the initial data
%  -------- select the files
% run single predict N times




% for use with 107
%DATA_PATH      =  'P:\GITHUBS\AIDATA\107_DB_0__4\Block_data_5_Labs_11_threshVALS_86_tests.mat'  ;  %  ::: File_labels: {'clear'  'clear'  'monitor'  'change'  'change'}
%DATA_PATH      =  'P:\GITHUBS\AIDATA\107_DB_0__4\Block_data_5_Labs_11_threshVALS_86_tests_2.mat'  ; %  ::: File_labels: {'zero'    'one'     'two'     'three'    'four'}

%DATA_PATH      =  'P:\GITHUBS\AIDATA\107DB_0_4_new_withHS\Block_data_5_Labs_11_threshVALS_95_tests.mat' ; %  ::: File_labels: {'zero'    'one'     'two'     'three'    'four'}

DATA_PATH       =  'P:\GITHUBS\AIDATA\107DB_0_4_new_withHS\Block_data_5_Labs_11_threshVALS_95_tests_2.mat' ; %  ::: File_labels: {'clear'  'clear'  'monitor'  'change'  'change'}

% for use with 120
% DATA_PATH      = 'P:\GITHUBS\AIDATA\120_new_long\Processed_data\Block_data_6_Labs_11_threshVALS_64_tests.mat'; %  ::: File_labels: {'zero'    'one'     'two'     'three'    'four'   'five'}
% DATA_PATH      = 'P:\GITHUBS\AIDATA\120_new_long\Processed_data\Block_data_6_Labs_11_threshVALS_64_tests_2.mat';%  ::: File_labels: {'clear'  'clear'  'monitor'  'change'  'change' 'change'}


%DATA\NEW_LEARNING_SET_2\Block_data_6_Labs_3_threshVALS_71_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_3\Block_data_6_Labs_10_threshVALS_64_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_3\Block_data_6_Labs_14_threshVALS_64_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_1\Block_data_6_Labs_14_threshVALS_77_tests.mat'
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_2\Block_data_6_Labs_14_threshVALS_71_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_3\Block_data_6_Labs_14_threshVALS_64_tests_2.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\NEW_LEARNING_SET_1\Block_data_6_Labs_2_threshVALS_77_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\120_new_long\Processed_data\Block_data_6_Labs_10_threshVALS_64_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\107_1\Processed_120_0_3_5\Block_data_3_Labs_11_threshVALS_38_tests.mat';
%DATA_PATH    = 'P:\GITHUBS\AIDATA\107_1\Processed_data_120\Block_data_6_Labs_11_threshVALS_62_tests.mat';

% %0/1/2/3/4/
% DATA_PATH    = 'P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_5_Labs_12_threshVALS_25_tests.mat'; 

% 0/3/4
% DATA_PATH    = 'P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_3_Labs_11_threshVALS_15_tests.mat';   

% 01/2/3/4    zero two three four
% DATA_PATH    =  'P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_5_Labs_11_threshVALS_25_tests.mat';

% 01/23/4 --  zero two four
%DATA_PATH    = 'P:\GITHUBS\AIDATA\107_2_new\Processed_data\Block_data_5_Labs_10_threshVALS_25_tests.mat';

block_file_ = DATA_PATH(max(strfind(DATA_PATH,'\'))+1:end);
dummy = open(DATA_PATH);
Block_DATA = dummy.Block_DATA;

labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'};

% --------------------------------------------------------------------------------------------------------- %
% ---------1-----2------3-----4-----5-----6-----7-----8-----9----10----11----12----13----14----15----16--- % 
% --------------------------------------------------------------------------------------------------------- %

%  1-2 / 2-1  / 2-4  /  4-2  
%  2   / 5    / 8    /  14   -----   11 is  3/3

% 2 / 5 / 8 /  11  /14

%mode_pairs_to_Use = [1,3,6,9,11,14,16];
%mode_pairs_to_Use = [8,14];
%mode_pairs_to_Use = [2,8,11,14]
%mode_pairs_to_Use = [1:16]; 

mod_pair_used = '';
for index = 1:length(mode_pairs_to_Use)
if index == length(mode_pairs_to_Use)
insert_ = '.';    
else
insert_ = ',';    
end
mod_pair_used = [mod_pair_used,labels{mode_pairs_to_Use(index)},insert_];
end %if index == length(mode_pairs_to_Use)

NumNeighbors      = 3       ;

% Slice_index       = 6       ;
% Thresh_index      = 5       ;
[slice_options,slice_indices] = get_slice_options_(Block_DATA.max_number_of_slices);


choices_1= arrayfun(@(a)num2str(a),slice_options,'uni',0) ;
[Slice_index,~] = listdlg('PromptString','Choose Number of averages (slices)', 'ListString',choices_1,'SelectionMode','single' );
choices_2 = arrayfun(@(a)num2str(a),Block_DATA.threshold_value,'uni',0) ;
[Thresh_index,~] = listdlg('PromptString','Choose Threshold Value', 'ListString',choices_2,'SelectionMode','single' );


Thresh_val_ = Block_DATA.threshold_value(Thresh_index);
no_slices = slice_options(Slice_index);

P_W_D = pwd;
cd('P:\GITHUBS\AIDATA')
[FILES_TO_PREDICT,file_path_] = uigetfile('*.mat',  'Selec the file to Predict','MultiSelect','on');

cd(P_W_D)


s_TXT_= '-----------------------------------------------------------------\n' ;
s_TXT_= [s_TXT_,'Threshold choice is: ', num2str(Thresh_val_),'.\n']                   ;
s_TXT_= [s_TXT_,'The number of slices of average: ',num2str(no_slices),'.\n']          ;
s_TXT_= [s_TXT_,'Block file used: ', block_file_ ,'.\n']          ;
s_TXT_= [s_TXT_,'#mode pairs used: ', num2str(length(mode_pairs_to_Use)),'.\n']          ;
s_TXT_= [s_TXT_,'NumNeighbors: ', num2str(NumNeighbors),'.\n']          ;
s_TXT_= [s_TXT_,'Mode Pairs used: ',mod_pair_used,'\n']                           ;
s_TXT_= [s_TXT_,'-----------------------------------------------------------------\n'] ;

fprintf(s_TXT_)
settings_.Thresh_val_   =Thresh_val_ ;
settings_.no_slices     = no_slices;
settings_.block_file_   =block_file_; 
settings_.mode_pairs_to_Use = mode_pairs_to_Use;
settings_.NumNeighbors    = NumNeighbors;
settings_.mod_pair_used   = mod_pair_used;
settings_.DATA_PATH       = DATA_PATH;
settings_.file_path_      = file_path_;
settings_.FILES_TO_PREDICT = FILES_TO_PREDICT;
settings_.s_TXT_   = s_TXT_  ;

file_nominal_Cr_Length = NaN(1,length(FILES_TO_PREDICT));


for index = 1 : length(FILES_TO_PREDICT)
%disp(FILES_TO_PREDICT{index})
%disp( FILES_TO_PREDICT{index}(find(FILES_TO_PREDICT{index}=='H')+1))    

file_nominal_Cr_Length(index)       = str2num(FILES_TO_PREDICT{index}(find(FILES_TO_PREDICT{index}=='H')+1));
file_nominal_Cr_Length_index(index) = file_nominal_Cr_Length(index)+1;
file_tag_index(index)               = Block_DATA.conversion_key(file_nominal_Cr_Length_index(index));

%--------------------------------------
%compiled_data
%--------------------------------------    

OP{index} =  predict_a_test_result_paul([file_path_,FILES_TO_PREDICT{index}]  ,DATA_PATH,mode_pairs_to_Use,NumNeighbors,Slice_index,Thresh_index);

fprintf(['/', num2str(index),'/'])
end %for index = 1 : length(FILES_TO_PREDICT)

compiled_data.OP = OP ;
fprintf('\n')

PREDICT_STRUCT.FILENAME = FILES_TO_PREDICT';

for index = 1: length(OP)
FL_TEMP{index}   =  OP{index}.file_label;
PL_TEMP{index}    =  OP{index}.PL;
AI_TEMP{index}    =  OP{index}.predict{1};
DM_TEMP{index}  =  OP{index}.predict{2};
LL_TEMP{index}    =  OP{index}.predict{3}; 
end

crack_lengths__  = get_num_from_cell_array( FL_TEMP');
peak_position_mm__  = get_num_from_cell_array(PL_TEMP');


PREDICT_STRUCT.FILENAME = FILES_TO_PREDICT';
%PREDICT_STRUCT.FILENAME = categorical(PREDICT_STRUCT.FILENAME);


PREDICT_STRUCT.File_Label  = crack_lengths__;

PREDICT_STRUCT.AI = AI_TEMP';
PREDICT_STRUCT.AI = categorical(PREDICT_STRUCT.AI);


PREDICT_STRUCT.Dist_Mean = DM_TEMP';
PREDICT_STRUCT.Dist_Mean = categorical(PREDICT_STRUCT.Dist_Mean);

PREDICT_STRUCT.Log_Lik = LL_TEMP';
PREDICT_STRUCT.Log_Lik = categorical(PREDICT_STRUCT.Log_Lik);

PREDICT_STRUCT.PEAK_mm = peak_position_mm__;

PREDICT_STRUCT_temp = PREDICT_STRUCT;
PREDICT_STRUCT_temp.FILENAME = categorical(PREDICT_STRUCT_temp.FILENAME);


PREDICT_Table = struct2table(PREDICT_STRUCT_temp);


disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(PREDICT_Table)
disp('-------------------------------------------------------------------------------------------------------------------------------------')


%,pred_score,pred_consitancy

[ind_of_3_predictions, conc_ , rating_ ,pred_score,pred_consitancy] =   get_consensus(AI_TEMP',DM_TEMP',LL_TEMP',Block_DATA.Labels_, Block_DATA.conversion_key , crack_lengths__);
cut_down_labels =    get_cut_down_file_labels(FILES_TO_PREDICT'); 

disp('-------------------------------------------------------------------------------------------------------------------------------------')

PREDICT2_STRUCT.TESTNAME = cut_down_labels';
PREDICT2_STRUCT.TESTNAME = categorical(PREDICT2_STRUCT.TESTNAME);

PREDICT2_STRUCT.Crack_Length = crack_lengths__;

PREDICT2_STRUCT.Prediction = conc_;
PREDICT2_STRUCT.Prediction = categorical(PREDICT2_STRUCT.Prediction);

PREDICT2_STRUCT.Rating = rating_;
PREDICT2_STRUCT.Rating = categorical(PREDICT2_STRUCT.Rating);

PREDICT2_STRUCT.Location = peak_position_mm__;
PREDICT2_Table = struct2table(PREDICT2_STRUCT);

disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(PREDICT2_Table)
disp('-------------------------------------------------------------------------------------------------------------------------------------')
disp(['Prediction rating: ',num2str(pred_score(3)),'%, (',num2str(pred_score(1)),'/',num2str(pred_score(2)),').'])
disp(['Prediction consistancy: ',num2str(pred_consitancy(3)),'%, (',num2str(pred_consitancy(1)),'/',num2str(pred_consitancy(2)),').'])
disp('-------------------------------------------------------------------------------------------------------------------------------------')

settings_.file_nominal_Cr_Length        =          file_nominal_Cr_Length       ;
settings_.file_nominal_Cr_Length_index  =          file_nominal_Cr_Length_index ;
settings_.file_tag_index                =          file_tag_index               ;


compiled_data.settings_                 =          settings_                    ; 
compiled_data.PREDICT_STRUCT            =          PREDICT_STRUCT               ;


compiled_data.PREDICT2_STRUCT           =          PREDICT2_STRUCT              ;
compiled_data.ind_of_3_predictions      =          ind_of_3_predictions         ;


compiled_data.pred_score                =          pred_score                   ;
compiled_data.pred_consitancy           =          pred_consitancy              ; 


% save compiled data in the data directory

cd(file_path_)
dum =dir('compiled_data#*.mat');
file_n =length(dum)+1;
f_name =['compiled_data#',num2str(file_n),'.mat']; 
save(f_name,'compiled_data');
cd(P_W_D)

% settings_
end %function predict_multiple_paul( )
%--------------------------------------------------------------------------------------------------------------------

function cut_down_labels =    get_cut_down_file_labels(file_name)

for index = 1: length(file_name)
dummy = file_name{index};

cut_down_labels{index} = dummy(max(find(dummy == 'H')):find(dummy == '.')-3);

end %for index = 1: length(file_name)

end %function cut_down_labels =    get_cut_down_file_labels(file_name)

function num_array  = get_num_from_cell_array(cell_array)

num_array =  -1*ones(size(cell_array)); 



for index = 1:length(cell_array)
num_array(index) =  str2num(cell_array{index}) ;
end % for index = 1:length(cell_array)

end % function num_array  = get_num_from_cell_array(cell_array)

function [ full_ind, conc_ ,rating_ , pred_score , pred_consitancy ]    =   get_consensus( AI , Dist_Mean , Log_Lik , Labels , conversion_key,crack_lengths__)

Labels = cell(Labels);
full_ind            =    -1 * ones(length(AI),3);

for index = 1 :length(AI)
full_ind(index,1) = find(contains(Labels,AI{index}))             ;
full_ind(index,2) = find(contains(Labels,Dist_Mean{index}))      ;
full_ind(index,3) = find(contains(Labels,Log_Lik{index}))        ;
end % for index = 1 :length(AI)

rating_nums  =  -1*ones( length(crack_lengths__) , 2);
conc_nums    =  -1*ones( length(crack_lengths__) , 1);

for index = 1: size(full_ind,1)
temp_ = full_ind(index,:)  ;

switch( length(unique(temp_)) )

    case(1) 
    conc_   {index}    =     Labels{mode(temp_)}    ; 
    rating_ {index}    =     '3/3'                  ;
    
    conc_nums(index)   =      mode(temp_)           ;
    rating_nums(index,:) =    [3,3]                 ;         

    case(2)
    conc_   {index}    =     Labels{mode(temp_)}    ;
    rating_ {index}    =    '2/3'                   ;
    conc_nums(index)  =      mode(temp_)            ;
    rating_nums(index,:) =   [2,3]                  ;

    case(3)
    conc_   {index}    =     Labels {ceil(mean(temp_))};
    rating_ {index}    =    'cM'                       ;
    conc_nums(index)  =      ceil(mean(temp_))         ;
    rating_nums(index,:) =   [1,3]                     ;

end %switch( length(unique(temp_)) )

end %for index = 1: size(full_ind,1)
conc_    = conc_'    ;
rating_  = rating_'  ;


nom_clasification = conversion_key(crack_lengths__+1)';
pred_clasifiaction = conc_nums ;

pred_score = [sum(pred_clasifiaction == nom_clasification),length(nom_clasification),100*sum(pred_clasifiaction == nom_clasification)/length(nom_clasification)];

dum = sum(rating_nums) ;
pred_consitancy = [dum(1),dum(2),100*dum(1)/dum(2)]  ;

end %function conc=   get_consensus(AI,Dist_Mean,Log_Lik)






function [slice_options ,  slice_indices] = get_slice_options_(max_number_of_slices)
slice_options = [1:2:max_number_of_slices];
central_val = ceil(max_number_of_slices/2);
for index = 1: length(slice_options)
amount_to_PM = floor(slice_options(index)/2);
slice_indices{index} =  [(central_val-amount_to_PM): (central_val+amount_to_PM)];
end %for index = 1: length(slice_options)
%slice_indices
end %function slice_options = get_slice_options(Block_DATA.max_number_of_slices);
