function combined_data   =  predict_multiple_tests(varargin) 
% input #  4-  select the block file  #5 the file is specified as he 5th input 

do_plots = 0 ; 
disp_overall_settings =1 ;


% overall settings
% make the data block so that it -
%  (1)  sets the tags automatically  ---    put the mapping into the start  of the program
%  (2)  sets the search limits automatically
%  (3)  does the rangeof %%  from  0 -- 100;
%  create a block data file with a range of percentage peaks
%  [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
% combined_data = predict_multiple_tests(1,2,[8,9,14,16],[0.65,0.8],'P:\GITHUBS\AIDATA\120-4bolt-no-wear\Block_data_6_L73_DV_065_8_6GR.mat')
% combined_data = predict_multiple_tests(1,2,[8,9,14,16],[0.65,0.8],'P:\GITHUBS\AIDATA\120-4bolt-no-wear\Block_data_6_L73_DV_065_9_6GR.mat')


% P:\GITHUBS\AIDATA\120-4bolt-no-wear\Processed_data

% needs  to be 4 or 5 inputs
%     1,2,[8,14],[0.65,0.8]
% overall_settings

if nargin ~= 4  ||  nargin ~= 5
normalising_mode_index = varargin{1};
std_bar_size           = varargin{2};  
mode_pairs_to_Use      = varargin{3}; 
search_limits          = varargin{4};

% select the learning set
if nargin ==5
Block_file = varargin{5};
file_ =  Block_file(max(find(Block_file=='\'))+1:end-4);
else
P_W_D = pwd ;
cd('P:\GITHUBS\AIDATA')
[file_,path_]=uigetfile();
Block_file = [path_,file_];
cd(P_W_D)
end %if nargin ==1

dummy = open(Block_file);
Block_DATA = dummy.Block_DATA;

% keyboard
% close(Block_file)

choices_=arrayfun(@(a)num2str(a),Block_DATA.Percentage_Peaks,'uni',0);

[Pecentage_peak_index,~] = listdlg('PromptString','Choose Percentage Peak', 'ListString',choices_,'SelectionMode','single' );
PP_string = num2str(Block_DATA.Percentage_Peaks(Pecentage_peak_index));

overall_settings.Block_file              = file_                                                                              ;
overall_settings.block_file_location     = Block_file(1:max(find (Block_file =='\')))                                         ;
overall_settings.normalising_mode_index  = normalising_mode_index                                                             ;
overall_settings.std_bar_size            = std_bar_size                                                                       ; 
overall_settings.mode_pairs_to_Use       = mode_pairs_to_Use                                                                  ;
overall_settings.search_limits           = search_limits                                                                      ;
overall_settings.labels                  = {' 1-1 ',' 1-2 ',' 1-3 ',' 1-4 ',' 2-1 ',' 2-2 ',' 2-3 ',' 2-4 ',' 3-1 ',' 3-2 ',' 3-3 ',' 3-4 ',' 4-1 ',' 4-2 ',' 4-3 ',' 4-4 '}   ; 
overall_settings.Percentage_Peak         = PP_string                  ; 
overall_settings.File_labels             = Block_DATA.File_labels     ;

overall_settings.txt{1}='-----------------------------------------------------------------\n'                  ; 
overall_settings.txt{1}= [overall_settings.txt{1},'-----------------------------------------------------------------\n']                                                                         ;
overall_settings.txt{1}= [overall_settings.txt{1},'File Name:',overall_settings.Block_file,'\n']                                                                         ;
overall_settings.txt{1}= [overall_settings.txt{1},'Norm mode pair: ' ,num2str(overall_settings.normalising_mode_index),'\n']                                                       ;
overall_settings.txt{1}= [overall_settings.txt{1},'Pairs used ' ,strcat(overall_settings.labels{ overall_settings.mode_pairs_to_Use}) ,'\n']                                      ;
overall_settings.txt{1}= [overall_settings.txt{1},'Search Limits:  [',num2str(overall_settings.search_limits(1)),' : ',num2str(overall_settings.search_limits(2)),']. \n']     ;
overall_settings.txt{1}= [overall_settings.txt{1},'Percentage_peak: ',num2str(overall_settings.Percentage_Peak),'. \n']                                                       ;
overall_settings.txt{1}= [overall_settings.txt{1},'-----------------------------------------------------------------\n']                                                                         ;
overall_settings.txt{1}= [overall_settings.txt{1},'-----------------------------------------------------------------\n']                                                                         ;


if disp_overall_settings ==1
fprintf(overall_settings.txt{1});
end %if disp_overall_settings ==1

% if no argument then select the black file
% predict_multiple_tests('P:\GITHUBS\AIDATA\Learning_block_2\Block_data_45_PP_4_L48_DV_1.mat')

% Select the files  
P_W_D =  pwd;
cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[filename_,path_] = uigetfile('*.mat',  'mat Files (*.mat)','MultiSelect','on'); 
cd (P_W_D)

% = get_file_label() 


if iscell(filename_)==1

for index = 1:length(filename_)

file_label = filename_{index}(find(filename_{index}=='H')+1);
File_to_Predict = [path_,filename_{index}];
summary_results{index} = predict_a_test_result(normalising_mode_index,std_bar_size ,mode_pairs_to_Use,search_limits,Block_file,Block_DATA, File_to_Predict, Pecentage_peak_index);
summary_results{index}.file_label  =  file_label ; 

end % for index = 1:length(filename_)

else
File_to_Predict = [path_,filename_];
summary_results{1} = predict_a_test_result(normalising_mode_index,std_bar_size ,mode_pairs_to_Use,search_limits,Block_file,Block_DATA, File_to_Predict, Pecentage_peak_index);
end %if iscell(filename_)==1


if do_plots ==1
do_peak_plots(summary_results,PP_string)
do_stat_plots(summary_results,PP_string)  
do_mode_plots(summary_results,PP_string)
end %if do_plots ==1

else
disp('must have 4 or 5 inputs')
end

combined_data.summary_results   = summary_results;
combined_data.overall_settings  = overall_settings;


save_folder = File_to_Predict(1: max(find(File_to_Predict=='\')));
block_file_name = Block_file(max(find (Block_file =='\'))+1:end);
sample_group_size = length(filename_);

save_combined_data(combined_data,PP_string,save_folder,block_file_name,sample_group_size,search_limits ) 

cd (P_W_D)


% save it in thefolder where the predicted data was 
% Save file  as block file name  _CD#No#
% find out which ones exist already - increment by 1

% Select the files  
end %function predict_multiple_tests(Block_file) 

function text_ = remove_(text_)
text_(find(text_=='_')) =  ' ';
end %function text_  remove_(text_)

function  save_combined_data(combined_data,PP_string,save_folder,block_file_name,sample_group_size,search_limits )
cd(save_folder)
SL = [num2str(round(search_limits(1)*100)),'_',num2str(round(search_limits(2)*100))];
name_stem = ['COMB_DATA__BD_',block_file_name(12:end-4),'_PP',PP_string,'_GS',num2str(sample_group_size),'SL',SL,'#*.mat'];

num_existing_files = length(dir(name_stem));
name_to_use = [name_stem(1:end-6),'#',num2str(num_existing_files+1),'.mat'];

save(name_to_use, 'combined_data' ,"-v7.3")
end % function  save_combined_data(combined_data,PP_string,save_folder,block_file_name)



