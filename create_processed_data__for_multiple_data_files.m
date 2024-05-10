function create_processed_data__for_multiple_data_files()

% Use fixed operator/test settings or current values from SETTINGS_FILES
use_current_O_T_settings = 0 ;    %(current means not from fixed values at time of test)

if use_current_O_T_settings == 1
cd ('SETTINGS_FILES')
[test_settings_from_folder     , ~ ] = load_structure_from_file('Test_Settings.dat'      ); 
[operator_settings_from_folder , ~ ] = load_structure_from_file('Operator_Settings.dat'  ); 
cd('..')
end %if use_current_O_T_settings == 1

%------------------------------------------------------------------------
%------------------------------------------------------------------------
%  Copy the filesover first
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% 1/ create_rail_tester_structure
% 2/ fn_proccess_rail_data
% 3/ save_processed_data( )
% 4/ default_options and proc_options  (create copies in the contact_AI)
%    What is the location of these in the worrking app?   
% 5/ test_settings (to start with use the fixed)
% 6/ operator_settings  (to start with use the fixed)
%    What is the location of these in the worrking app?   
%------------------------------------------------------------------------
%------------------------------------------------------------------------
%  Select multiple files
%  Take the default_options and proc_options  from the contact ai file
%  Create a folder processed_data as a sub folder to the data being processed
%  Process the data and save as PD_(file_name)  in a sub folder to the data     <-->   could use the 
%  Save_processed_data  to do this
%------------------------------------------------------------------------
%------------------------------------------------------------------------
p_w_d = pwd;
cd('P:\GITHUBS\AIDATA')
%   select the files
[filename_,path_] = uigetfile('*.mat',  'mat Files (*.mat)','MultiSelect','on') ; 
if  exist([path_,'Processed_data']) ==0
mkdir([path_,'Processed_data']);
end
saving_dir =  [path_,'Processed_data'] ;

cd(p_w_d)
% load structure from file

cd ('SETTINGS_FILES')
[default_options ,~] = load_structure_from_file('default_options.dat');
[proc_options,~] = load_structure_from_file('proc_options_.dat'); 
cd('..')

%  need to chck that it actually is a processed data file
% load in the proc settings and default settings here 


for index = 1:length(filename_)
dummy_ = load([path_,filename_{index}]); 
disp(['Loading... ', filename_{index},'...' ])

if numel(fields(dummy_))==1 && strcmp(fields(dummy_),'test_data')
    
test_data = dummy_.test_data                                          ;
if use_current_O_T_settings == 1   % current not fixed                ;
test_data.fixed_Test_Settings       = test_settings_from_folder       ;
test_data.fixed_Operator_Settings   = operator_settings_from_folder   ;
end %if use_current_O_T_settings == 1   % current not fixed           ;

[rail_tester,loaded_fe_file_ok ]  =  create_rail_tester_structure(default_options,dummy_.test_data,proc_options);

if loaded_fe_file_ok ==1
rail_tester = fn_process_rail_data(rail_tester,proc_options);

cd(saving_dir)
FN_ = filename_{index};


numb_files = length(dir(['PD_',FN_(1:end-4),'_*','.mat']));
sug_file_name_ = ['PD_',FN_(1:end-4),'_',num2str(numb_files+1),'.mat'];

save([saving_dir,'\',sug_file_name_],'test_data','rail_tester','proc_options')

disp(['Saved...', sug_file_name_, '...' ])
cd(p_w_d)

else
    disp ([filename_{index},' FE file not loaded correctly -- skipping' ])
end %if loaded_fe_file_ok ==1

else
disp ([filename_{index},' doest appear to be a test data file (should have one field with the name test_data -- skipping' ])
end  %if numel(fields(dummy))==1 && strcmp(fields(dummy),'test_data')
end  %for index = 1:length(filename_)

end % function process_multiple_data_files()







