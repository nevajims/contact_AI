function [] = plot_predict_processed_multiple()


% output tables of the predictions     
% tables of the quality indictors :    peak location / SNR indictors / capacitance check values

% Any plots ?    -- >>  means_v_tag/result --  for each  MP  POSS


%-------------------------------------------------------
% Put in options to see the data quality plots
% snr_settings_O = convert_to_snr_struct(app.snr_settings)
% plot_SNR_Raw(app.test_data,[0,0,1,0],snr_settings_O)
%-------------------------------------------------------
%
%
%
%
%
%
%---------------------------------------------------------------------------------------------------
% prediction plots
%---------------------------------------------------------------------------------------------------
do_plots = [0 0 0 0 0 0 0 0 0 0 0 0];
plot_list =   {'Peak find','Mode pairs','Single Mode map','mean/std of modes','MM Viewer','Tag MMs','Predictions','DFM table','LL Table','Overall Prediction','all mean/stds','means_v_tag/result' };
do_plots_dum =  choose_plots_to_show(plot_list);
do_plots(find(do_plots_dum ==1)) = 1;
%---------------------------------------------------------------------------------------------------

% QUALITY PLOTS
%---------------------------------------------------------------------------------------------------
plot_list_2 =   {'Maps','Bar Charts','indicators','time_freq_traces' } ;
do_plots_2 =[0 0 0 0];
do_plots_dum_2 =  choose_plots_to_show(plot_list_2);
do_plots_2(find(do_plots_dum_2 ==1)) = 1;
%---------------------------------------------------------------------------------------------------

P_W_D = pwd ;
starting_dir  =  'P:\GITHUBS\AIDATA';

if exist(starting_dir) == 7  
cd(starting_dir)
end %if (exist('P:\GITHUBS\AIDATA')) == 7  

[DATA_FILE_TO_PREDICT,file_path_2,ok_ ] = uigetfile('*.mat',  'Selec the learning set','MultiSelect','off');



if ok_ ==1

dummy = load([file_path_2,DATA_FILE_TO_PREDICT]);
Block_DATA = dummy.Block_DATA   ;



settings_              = load_structure_from_file('P:\GITHUBS\contact_AI\SETTINGS_FILES\plot_options2.dat');
%snr_settings_          = load_structure_from_file('P:\GITHUBS\contact_AI\SETTINGS_FILES\snr_settings2.dat');  


labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'};
DP =  [file_path_2,DATA_FILE_TO_PREDICT] ;

[FILES_TO_PREDICT,file_path_,ok_2] = uigetfile('*.mat',  'Selec the file to Predict','MultiSelect','on');




if ok_2 ==1

disp('----------------------------------------------------------------------------------')
disp('----------------------------------------------------------------------------------')
disp(['Location of Learning File:   ',file_path_2, '.'])
disp(['Learning File:   ',DATA_FILE_TO_PREDICT, '.'])
disp('----------------------------------------------------------------------------------')
disp((Block_DATA.File_labels))
disp('MPs: ')
disp(labels(settings_.mode_pairs_to_Use))
disp(['conversion key:', num2str(Block_DATA.conversion_key)])
disp(['No of files in block: ', num2str(length(Block_DATA.tag_label_index)),'.'])
disp('----------------------------------------------------------------------------------')
disp(['Data file path: ', file_path_])
disp('----------------------------------------------------------------------------------')

if iscell(FILES_TO_PREDICT) % multiple files chosen

for index = 1:length(FILES_TO_PREDICT)

proc_file_temp   =  [file_path_,FILES_TO_PREDICT{index}]             ;
pred_temp =   plot_predict_processed(proc_file_temp, DP , do_plots)  ;  
[~]=  plot_SNR_Raw(proc_file_temp,do_plots_2);
disp([FILES_TO_PREDICT{index} ,'|||||'  ,pred_temp.Labels{pred_temp.pred_value},'|||||         (AI:' pred_temp.ai_tag,', DFM: ',pred_temp.DFM_tag,', LL:',pred_temp.LL_tag,').'] )
end %for index = 1:length(FILES_TO_PREDICT)

else %  only 1 file is chosen

proc_file_temp   =  [file_path_,FILES_TO_PREDICT]             ;
pred_temp =   plot_predict_processed(proc_file_temp, DP , do_plots)  ;  
[a_tmp]   =  plot_SNR_Raw(proc_file_temp,do_plots_2);
disp([FILES_TO_PREDICT ,'|||||'  ,pred_temp.Labels{pred_temp.pred_value},'|||||         (AI:' pred_temp.ai_tag,', DFM: ',pred_temp.DFM_tag,', LL:',pred_temp.LL_tag,').'] )


end    
disp('----------------------------------------------------------------------------------')

cd(P_W_D)
else
cd(P_W_D)
disp('bailed')
end %if ok_2 ==1




else
cd(P_W_D)
disp('bailed')
end %if ok_ ==1




%proc_file            =  varargin{1}                                 ; 
%DP                   =  varargin{2}                                 ; 
%do_plots             =  varargin{3}                                 ;
end %function [outputArg1,outputArg2] = plot_predict_processed_multiple()

function do_plots =  choose_plots_to_show(plot_list)
[ones_,~] = listdlg('ListString',plot_list);
do_plots(ones_) = 1;
end %function do_plots =  choose_plots_to_show(plot_list);

