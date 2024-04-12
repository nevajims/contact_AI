function combined_data   =  predict_multiple_tests(varargin) 


do_plots = 0 ; 
disp_overall_settings =1 ;

% overall settings

% make the data block so that it -
%  (1)  sets the tags automatically  ---    put the mapping into the start  of the program
%  (2)  sets the search limits automatically
%  (3)  does the rangeof %%  from  0 -- 100;
%  create a block data file with a range of percentage peaks

%  [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]


% predict_multiple_tests(1,2,[8,9,14,16],[0.65,0.8],'P:\GITHUBS\AIDATA\Learning_block_2\Block_data_6_L48_DV.mat')
% needs  to be 4 or 5 inputs

%     1,2,[8,14],[0.65,0.8]

%overall_settings


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

overall_settings.Block_file              = file_;

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

%
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

end


else
disp('must have 4 or 5 inputs')
end

combined_data.summary_results   = summary_results
combined_data.overall_settings  = overall_settings




% Select the files  
end %function predict_multiple_tests(Block_file) 




function do_peak_plots(SR,PP_string)
sub_plots_inds = [1,1;2,1;3,1;2,2;3,2;3,2;4,2;4,2; 3,3;3,4;3,4;3,4;4,4;4,4;4,4;4,4];
fig_ = figure ;



for index = 1: length(SR)

title_ = remove_((SR{index}.file_name));
SB_= subplot( sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index );    


plot_data = SR{index}.plot_data{1};
dv          = plot_data.dv                        ;
mm33        = plot_data.mm33                      ;
lower_index = plot_data.lower_index                ;

upper_index = plot_data.upper_index                ;
max_ind    =  plot_data.max_ind                     ;
max_val    =  plot_data.max_val                ;
plot(dv,mm33,"Color",'b') 
hold on
plot( [dv(lower_index),dv(lower_index)],[min(mm33),max(mm33)  ],'r')
plot( [dv(upper_index),dv(upper_index)],[min(mm33),max(mm33)  ],'r')
plot(dv(max_ind), max_val,'o','markersize', 10 );
title ([title_,'; Pk = ',num2str(dv(max_ind)*1000),'mm'])
end% for index = 1: length(SR)


sgtitle(['Percentage Peak = ' , PP_string , '%.']) 

end %function do_peak_plots(SR)


function do_stat_plots(SR,PP_string)

sub_plots_inds = [1,1;2,1;3,1;2,2;3,2;3,2;4,2;4,2;3,3];
fig_ =figure ;

for index = 1: length(SR)
% disp(num2str(index))

SB_= subplot( sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index );    


title_ = remove_((SR{index}.file_name));


plot_data = SR{index}.plot_data{2} ;

spec_vals_temp    = plot_data.spec_vals_temp ;
Block_DATA        = plot_data.Block_DATA ;
mode_pairs_to_Use = plot_data.mode_pairs_to_Use ;
labels            = plot_data.labels  ;
std_bar_size      = plot_data.std_bar_size  ;
block_file_       = plot_data.block_file_ ;

val_nos_tmp = 1:16;

xBlanks = zeros(1, length(mode_pairs_to_Use));


subplot(SB_)
hold on


title(['TEST:: ',title_])

for index_2 = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index_2},1,numel(Block_DATA.mean_tag_modes_{index_2}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index_2},1,numel(Block_DATA.std_tag_modes_{index_2}));
errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)

end %for index_2 = 1: length(Block_DATA.Labels_)

legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');


xlim([0,length(mode_pairs_to_Use)+1])
xticklabels(labels(mode_pairs_to_Use))
xticks(1: length(mode_pairs_to_Use))

%axes( 'XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));


end % for index = 1: length(SR)
sgtitle(['Percentage Peak = ' , PP_string , '%.']) 


end %function do_peak_plots(summary_results)


function do_mode_plots(SR,PP_string)
db_range = 0.8      ; 
fig_  = figure      ;
sub_plots_inds = [1,1;2,1;3,1;2,2;3,2;3,2;4,2;4,2;3,3];


for index = 1: length(SR)
subplot(sub_plots_inds(length(SR),1),sub_plots_inds(length(SR),2),index)    

title_ = remove_((SR{index}.file_name));
interp_data = (SR{index}.plot_data{3});

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
end %for index = 1: length(SR)
sgtitle(['Percentage Peak = ' , PP_string , '%.']) 

end  %function do_mode_plots(SR)

function text_ = remove_(text_)
text_(find(text_=='_')) =  ' ';
end %function text_  remove_(text_)


