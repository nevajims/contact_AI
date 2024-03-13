function predict_multiple_tests(varargin) 


if nargin ==1
Block_file = varargin{1};
else
P_W_D = pwd ;
cd('P:\GITHUBS\AIDATA')
[file_,path_]=uigetfile();
Block_file = [path_,file_];
cd(P_W_D)
end %if nargin ==1


% if no argument then select the black file
% predict_multiple_tests('P:\GITHUBS\AIDATA\Learning_block_2\Block_data_45_PP_4_L48_DV_1.mat')

%
% Select the files  
P_W_D =  pwd;
cd('P:\GITHUBS\AIDATA')
%cd('C:\Users\Dev\OneDrive\shared from tti test\AIDATA')
[filename_,path_] = uigetfile('*.mat',  'mat Files (*.mat)','MultiSelect','on'); 
cd (P_W_D)

for index = 1:length(filename_)
predict_a_test_result(1,2,[8,9,14,16],[0.65,0.9],Block_file,[path_,filename_{index}])
end % for index = 1:length(filename_)


% Select the files  
 

end %function predict_multiple_tests(Block_file) 



