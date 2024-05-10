function  output_  =   predict_a_test_result(varargin)

% function  output_  =   predict_a_test_result(normalising_mode_index,std_bar_size ,mode_pairs_to_Use,search_limits, DATA_PATH , Block_DATA, FILE_TO_PREDICT, PP_index)
% 2 options for input  

% for use with predict_multiple_tests (8)
%-------------------------------------
% its called with another function  
% (normalising_mode_index,std_bar_size ,mode_pairs_to_Use,search_limits,
% DATA_PATH , Block_DATA, FILE_TO_PREDICT, PP_index)  -- 8 inputs 
%-------------------------------------

% for use as stand alone (4) (5)
%-------------------------------------
% 4 ---  predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9])
% 5 ---  predict_a_test_result(1,2,[8,14],[0.65,0.9],'P:\GITHUBS\AIDATA\120-4bolt-no-wear\Processed_data\Block_data_6_L65_DV _LongWIN.mat')
%  (normalising_mode_index , std_bar_size , mode_pairs_to_Use , search_limits)
%-------------------------------------


run_the_program = 1;

diplay_txt = [1 0 0 0 0 0 0 0 0 0 0];
%diplay_txt  = [1 1 1 1 1 1 1 1 1 1 1];

display_plots = [0 0 0];
%display_plots = [1 1 1];

switch(nargin)
    case(8)
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};
mode_pairs_to_Use      = varargin{3};
search_limits          = varargin{4};
DATA_PATH              = varargin{5};
Block_DATA             = varargin{6};
FILE_TO_PREDICT        = varargin{7};
PP_index               = varargin{8};

    case(4)
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};
mode_pairs_to_Use      = varargin{3};
search_limits          = varargin{4};
P_W_D = pwd ;
cd('P:\GITHUBS\AIDATA')
[file_,path_]=uigetfile();
DATA_PATH = [path_,file_];
cd(P_W_D)

    case(5)
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};
mode_pairs_to_Use      = varargin{3};
search_limits          = varargin{4};
DATA_PATH              = varargin{5};
    
    otherwise
disp('should have 8 arguments (for multi mode) or 4/5 arguments (for single mode)'  )        
run_the_program = 0;

end %switch(nargin)


if run_the_program ==1


if nargin == 4 || nargin == 5  
dummy = open(DATA_PATH);
Block_DATA = dummy.Block_DATA;

choices_=arrayfun(@(a)num2str(a),Block_DATA.Percentage_Peaks,'uni',0);
[PP_index,~] = listdlg('PromptString','Choose Percentage Peak', 'ListString',choices_,'SelectionMode','single' );

PP_string = num2str(Block_DATA.Percentage_Peaks(PP_index));

P_W_D =  pwd;
cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[filename_,path_] = uigetfile('*.mat',  'mat Files (*.mat)','MultiSelect','on'); 
cd (P_W_D)
FILE_TO_PREDICT = [path_,filename_];
end %if nargin == 4 || nargin == 5  

include_ai = 1;
include_LL = 1;

mode_pairs=  [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];

labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'}; 

normalising_mode_pair =  mode_pairs(normalising_mode_index,:);

NumNeighbors = 3 ;
%std_bar_size = 1.5;
show_tag_mean_mode_plots = 0 ;




block_file_ = DATA_PATH(max(strfind(DATA_PATH,'\'))+1:end);

%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_1\Block_data_45_PP_2_L8_DV.mat');

%Block_DATA = dummy.Block_DATA;
%---------------------------------------------- 






%output_.predict_tags = Block_DATA.Labels_ ;
Labels_ = Block_DATA.Labels_;
tag_label_index = Block_DATA.tag_label_index;

norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_   ,   normalising_mode_pair , PP_index );




for index = 1:length(Labels_)
%disp(['Tag = ',Labels_{index} ,'.'])
tag_indicies                   = find(tag_label_index == index);
tag_modes_ =   norm_crack_mode_(:,:,tag_indicies);
mean_temp = mean(tag_modes_ , 3) ;
mean_tag_modes_{index}         = mean_temp;
std_temp = std(tag_modes_,0,3)  ;
std_tag_modes_{index}          = std_temp;

Block_DATA.mean_tag_modes_ = mean_tag_modes_;
Block_DATA.std_tag_modes_  = std_tag_modes_;

if show_tag_mean_mode_plots == 1
interp_data = get_interp_data(mean_tag_modes_{index},50);
plot_interp_data(interp_data,[Labels_{index},':: mean values(normalised to 1-1)'],0.8)
interp_data = get_interp_data(std_temp./mean_temp,50);
plot_interp_data(interp_data,[Labels_{index},':: std over mean   '],0.8)
end %if show_tag_mean_mode_plots == 1
end %for index = 1:length(Labels_)

%  this will be done on the fly
%  this will be done on the fly
%dummy =  open(strcat(path_2,file_2));diplay_txt
%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_1\AI_Block_45_PP_2_L16_DV_NN_3_mat.mat');
%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_2\AI_Block_45_PP_6_L48_DV_NN_3_mat.mat');
% AI_Block = dummy.AI_Block;

if include_ai == 1
AI_Block  = Create_AI_learning_Block(NumNeighbors,mode_pairs_to_Use, norm_crack_mode_,Block_DATA.Labels_, Block_DATA.tag_label_index );
end %if include_ai == 1

[spec_vals, file_name, output_.plot_data{1} ] =  Get_mode_values_from_a_test(Block_DATA.Percentage_Peaks(PP_index)  , search_limits , FILE_TO_PREDICT , display_plots);

SV_crack_mode = spec_vals.crack_mode;
SV_crack_mode = SV_crack_mode./SV_crack_mode(normalising_mode_pair(1),normalising_mode_pair(2));

spec_vals_temp = reshape(SV_crack_mode, 1 , numel(SV_crack_mode));
output_.crack_mode_vals =  SV_crack_mode;
output_.file_name      =  file_name;
output_.block_file     =  DATA_PATH;

if include_ai == 1
[return_tag,~,~] = predict(AI_Block , spec_vals_temp(mode_pairs_to_Use));
end %if include_ai == 1

[Score_vals,output_.plot_data{2}]   = do_mean_std_plot(spec_vals_temp,Block_DATA,mode_pairs_to_Use,labels,std_bar_size,display_plots,file_name,block_file_);

[score_table,log_lik_table, rank_table, within_range_table,std_dist_table, predict_tag,LL_tag]    = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_,std_bar_size,include_LL);

file_label = file_name(find(file_name =='H')+1);


output_.txt{1}='-----------------------------------------------------------------\n'                  ; 
output_.txt{1}= [output_.txt{1},file_name,'\n']                                                       ;
output_.txt{1}= [output_.txt{1},'LABEL: ',file_label,'\n']                                          ;

output_.txt{1}= [output_.txt{1},'-----------------------------------------------------------------\n'];

if diplay_txt(1) ==1
fprintf(output_.txt{1})
end %if diplay_txt(1) ==1

output_.txt{2}= ['Peak location: ',num2str(spec_vals.Peak_loc),' mm.\n'];
if diplay_txt(2) ==1
fprintf(output_.txt{2})
end

output_.txt{3} = display_Block_data_stats(Block_DATA);

if diplay_txt(3) ==1
fprintf(output_.txt{3})

end


output_.txt{4} = ['normalising_mode_pair: ',num2str(normalising_mode_pair(1)),'/',num2str(normalising_mode_pair(2)),'.\n'];
if diplay_txt(4) ==1
fprintf(output_.txt{4})
end
if include_ai == 1
output_.txt{5} = ['The AI predicts that this results is:   ', return_tag{1} ,' .\n'];
output_.predict{1} = return_tag{1} ; 
else
output_.txt{5} = 'The AI prediction currently removed \n';
output_.predict{1} = NaN; 
end

if diplay_txt(5) ==1
fprintf(output_.txt{5})
end


if include_LL ==1
output_.txt{6} = ['The dist from mean predicts that the result is:   ',  predict_tag ,' .\n'];
output_.txt{6} = [output_.txt{6},'The log likelyhood predicts that the result is:   ',  LL_tag ,' .\n'   ];

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

% formatted_score_table = convert_table_to_formatted_txt(score_table); 
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

output_.txt{8} = '-----------------------------------------------------------------\n';
output_.txt{8} = [output_.txt{8}, 'Ranking for dist from mean\n'];
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];
output_.rank_table = rank_table;
TString = evalc('disp(output_.rank_table)');
TString = remove_strong(TString);
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];
output_.txt{8} = [output_.txt{8}, TString,                                                         '\n'];
output_.txt{8} = [output_.txt{8}, '-----------------------------------------------------------------\n'];

if diplay_txt(8) ==1
fprintf(output_.txt{8})
end

if include_LL ==1
output_.txt{9} = '-----------------------------------------------------------------\n';
output_.txt{9} = [output_.txt{9}, 'Log Likelyhood\n'];
output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];
output_.log_lik_table = log_lik_table;
TString = evalc('disp(output_.log_lik_table)');
TString = remove_strong(TString);
output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];
output_.txt{9} = [output_.txt{9}, TString,                                                         '\n'];
output_.txt{9} = [output_.txt{9}, '-----------------------------------------------------------------\n'];
else
output_.txt{9} = '-----------------------------------------------------------------\n';
output_.txt{9} = [output_.txt{9},output_.txt{9}, 'The Log Likelyhood table is not included\n'];
output_.txt{9} = [output_.txt{9},'-----------------------------------------------------------------\n'];
end

if diplay_txt(9) ==1
fprintf(output_.txt{9})
end


output_.txt{10} = '-----------------------------------------------------------------\n';
output_.txt{10} = [output_.txt{10}, 'Within range (+/- ',num2str(std_bar_size), ' * std).\n'];
output_.txt{10} = [output_.txt{10}, '-----------------------------------------------------------------\n'];
output_.within_range_table = within_range_table;
TString = evalc('disp(output_.within_range_table)');
TString = remove_strong(TString);
output_.txt{10} = [output_.txt{10}, '-----------------------------------------------------------------\n'];
output_.txt{10} = [output_.txt{10}, TString,                                                         '\n'];
output_.txt{10} = [output_.txt{10}, '-----------------------------------------------------------------\n'];


if diplay_txt(10) ==1
fprintf(output_.txt{10})
end

output_.txt{11} = '-----------------------------------------------------------------\n';
output_.txt{11} = [output_.txt{11}, 'No. of STD dist from mean\n'];
output_.txt{11} = [output_.txt{11}, '-----------------------------------------------------------------\n'];
output_.std_dist_table = std_dist_table;
TString = evalc('disp(output_.std_dist_table)');
TString = remove_strong(TString);
output_.txt{11} = [output_.txt{11}, '-----------------------------------------------------------------\n'];
output_.txt{11} = [output_.txt{11}, TString,                                                         '\n'];
output_.txt{11} = [output_.txt{11}, '-----------------------------------------------------------------\n'];


if diplay_txt(11) ==1
fprintf(output_.txt{11})
end

%if show_tag_mean_mode_plots == 1
%for index= 1: length(Block_DATA.Labels_)
%interp_data = get_interp_data(Block_DATA.mean_tag_modes_{index},50);
%plot_interp_data(interp_data,[Block_DATA.Labels_{index},':: BLOCK mean values(normalised to 1-1)'],0.8)
%end  % for index= 1: length(Block_DATA.Labels_)
%end %if show_tag_mean_mode_plots == 1

output_.plot_data{3} = get_interp_data(spec_vals.crack_mode,50);
if display_plots(3) ==1
plot_interp_data(output_.plot_data{3},file_name,0.8)
end %if display_plots(3) ==1

end % if run_the_program ==1

end  % function   predict_a_test_result



% manually or automatically
% check the FE get this bit correct
% normalising_mode_index = varargin{1};
% std_bar_size           = varargin{2};  
% mode_pairs_to_Use      = varargin{3}; 
% search_limits          = varargin{4};


% output_
% output_.txt{1-11} 
% output_.plots {1-3} 
% output_.tables  (by name as part of the txt data)  -  to be merged into the txt at some point

% use a structure for the variable inputs
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use ) Nargin = 3  
% predict_a_test_result(1,2,[8,9,14,16])
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits ) Nargin = 4 

% predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9])

% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits, DATA_PATH) Nargin = 5 
% function   predict_a_test_result(normalising_mode_index, std_bar_size, mode_pairs_to_Use,search_limits, DATA_PATH, FILE TO PREDICT) Nargin = 6

% predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9],'P:\GITHUBS\AIDATA\Learning_block_2\Block_data_45_PP_4_L48_DV_1.mat','P:\GITHUBS\AIDATA\Learning_block_2\PD_CW_test_Jim_Evans__H4CE$3$_1.mat')

% use vargin and nargin
% display_plots = [0 0 0];
% diplay_txt = [1 0 0 0 1 1 1 1 0 0 0 ];

% Position to take the mode map (Marked with circle)  and the region themax is searched for
% the mode plot means and stds --with the file name block data file name the title    
% mode map of the specific test at the postion identiified in Fig. 1

% display_plots = [1 1 1];

%diplay_txt = [1 1 1 1 1 1 1 1 0 0 0 ];
%diplay_txt = [1 1 1 1 1 1 1 1 1 1 1 ];
%display_plots = [1 1 1];
%diplay_txt = [0 0 0 0 0 0 0 0 0 0 0 ];

%{

if nargin > 2  &&  nargin < 8
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};  
mode_pairs_to_Use      = varargin{3};  
search_limits  = NaN                ;
DATA_PATH      = NaN                ; 
FILE_TO_PREDICT  = NaN              ;

switch(nargin)
     case(4)
search_limits          = varargin{4};
    case(5)
search_limits          = varargin{4};
DATA_PATH              = varargin{5}; 
    case(6)
search_limits          = varargin{4};
DATA_PATH              = varargin{5}; 
FILE_TO_PREDICT        = varargin{6};                     
    case(7)
search_limits          = varargin{4};
DATA_PATH              = varargin{5}; 
FILE_TO_PREDICT        = varargin{6};                     
PP_index               = varargin{7};   

    otherwise
end %switch(nargin)
else
end % if nargin > 2  &&  nargin < 7

%}

% DATA_PATH

% DONE  ------    Do a log likelyhood prediction using PDF  
% DONE  ------    Do a ranking for "within STD range"  1 / 0  where std range is selected 
% (3)  combine them together to do a full analysis of the data  -  for all the
% tests
% predict_a_test_result(1,[3,6,8,9,14,16])   ----  standard run
% mode_pairs_to_Use = [3,6,8,9,14,16];       %  %  this will be an input argument 
% normalisation_mode_pair =  1               %  %  (1,1) this will be an input argument
%{
if isnan(DATA_PATH)
    P_W_D = pwd ;
%  load a block data set 
%cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[file_,path_]=uigetfile();
DATA_PATH = [path_,file_];
dummy =  open(strcat(DATA_PATH));
cd(P_W_D)

else
dummy =  open(strcat(DATA_PATH));
end
%}






