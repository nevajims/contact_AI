function    save_processed_data(test_data , rail_tester,current_test_folder , proc_options)

TD_name = test_data.file_with_path(max(find(test_data.file_with_path=='\'))+1:end-4);

p_w_d = pwd;

if exist([current_test_folder,'Processed_data']) == 0
mkdir([current_test_folder,'Processed_data'])
end     % if exist([current_test_folder,'Processed_data']) == 0

cd([current_test_folder,'Processed_data'])

numb_files = length(dir(['PD_',TD_name,'_*','.mat']));
sug_file_name_ = ['PD_',TD_name,'_',num2str(numb_files+1),'.mat'];

% now  do the window to save
uisave({'test_data','rail_tester','proc_options'},sug_file_name_)

cd(p_w_d)

end %function    save_processed_data(   )
