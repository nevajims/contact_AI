%
function  output_  =  predict_a_test_result(varargin) 
include_ai = 1;
include_LL = 1;


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
% diplay_txt = [0 0 0 0 0 0 0 0 0 0 0];

display_plots = [1 1 1];
diplay_txt = [1 1 1 1 1 1 1 1 1 1 1 ];


% display_plots = [0 0 0];
% diplay_txt = [0 0 0 0 0 0 0 0 0 0 0 ];
%diplay_txt = [1 0 0 0 1 1 0 0 0 0 0 ];



if nargin > 2  &&  nargin < 7
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
    otherwise
end %switch(nargin)
else
end % if nargin > 2  &&  nargin < 7

% DATA_PATH




% DONE  ------    Do a log likelyhood prediction using PDF  
% DONE  ------    Do a ranking for "within STD range"  1 / 0  where std range is selected 
% (3)  combine them together to do a full analysis of the data  -  for all the
% tests
% predict_a_test_result(1,[3,6,8,9,14,16])   ----  standard run
% mode_pairs_to_Use = [3,6,8,9,14,16];       %  %  this will be an input argument 
% normalisation_mode_pair =  1               %  %  (1,1) this will be an input argument


mode_pairs=  [1,1;1,2;1,3;1,4;2,1;2,2;2,3;2,4;3,1;3,2;3,3;3,4;4,1;4,2;4,3;4,4];
labels = {'1-1','1-2','1-3','1-4','2-1','2-2','2-3','2-4','3-1','3-2','3-3','3-4','4-1','4-2','4-3','4-4'}; 

normalising_mode_pair =  mode_pairs(normalising_mode_index,:);
NumNeighbors = 3 ;
%std_bar_size = 1.5;
show_tag_mean_mode_plots = 0 ;

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

block_file_ = DATA_PATH(max(strfind(DATA_PATH,'\'))+1:end);


%dummy =  open('P:\GITHUBS\Liams_algos\Learning_block_1\Block_data_45_PP_2_L8_DV.mat');


Block_DATA = dummy.Block_DATA;

Labels_ = Block_DATA.Labels_;
tag_label_index = Block_DATA.tag_label_index;

norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_,normalising_mode_pair);



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

[spec_vals, file_name, output_.plot_data{1} ] =  Get_mode_values_from_a_test(Block_DATA.Peak_method , Block_DATA.Percentage_Peak , search_limits,FILE_TO_PREDICT,display_plots);

SV_crack_mode = spec_vals.crack_mode;
SV_crack_mode = SV_crack_mode./SV_crack_mode(normalising_mode_pair(1),normalising_mode_pair(2));
spec_vals_temp = reshape(SV_crack_mode, 1 , numel(SV_crack_mode));

if include_ai == 1
[return_tag,~,~] = predict(AI_Block , spec_vals_temp(mode_pairs_to_Use));
end %if include_ai == 1

[Score_vals,output_.plot_data{2}]   = do_mean_std_plot(spec_vals_temp,Block_DATA,mode_pairs_to_Use,labels,std_bar_size,display_plots,file_name,block_file_);

[score_table,log_lik_table, rank_table, within_range_table,std_dist_table, predict_tag,LL_tag]    = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Block_DATA.Labels_,std_bar_size,include_LL);


output_.txt{1}='-----------------------------------------------------------------\n'                      ; 
output_.txt{1}= [output_.txt{1},file_name,'\n']                                                                   ;
output_.txt{1}= [output_.txt{1},'-----------------------------------------------------------------\n']  ;

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
else
output_.txt{5} = 'The AI prediction currently removed \n';
end

if diplay_txt(5) ==1
fprintf(output_.txt{5})
end


if include_LL ==1
output_.txt{6} = ['The dist from mean predicts that the result is:   ',  predict_tag ,' .\n'];
output_.txt{6} = [output_.txt{6},'The log likelyhood predicts that the result is:   ',  LL_tag ,' .\n'   ];
else
output_.txt{6} = ['The dist from mean predicts that the result is:   ',  predict_tag ,' .\n'];
output_.txt{6} = [output_.txt{6},'The LL prediction currently removed \n'];
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
plot_interp_data(output_.plot_data{3},'SPECIFIC TEST mode plot',0.8)
end %if display_plots(3) ==1


end  % function   predict_a_test_result

% have it so you dont have to select the boundaries  --  option to do
% manually or automatically
% check the FE get this bit correct


function formated_output =  display_Block_data_stats(Block_DATA)

formated_output = 'Number of tests for each data set\n' ;

for index = 1:length(Block_DATA.Labels_)
formated_output = [formated_output,'Tag = ', Block_DATA.Labels_{index},'(',num2str(length(find(Block_DATA.tag_label_index==index))),')\n'];
end %for index = 1:length(Block_DATA.Labels_)

end %function display_Block_data_stats(Block_DATA);





function norm_crack_mode_ = normalse_crack_modes(crack_mode_,normalising_mode_pair)
for index = 1:length(crack_mode_)
norm_crack_mode_(:,:,index) = crack_mode_{index} / crack_mode_{index}(normalising_mode_pair(1),normalising_mode_pair(2));
end %for index = 1:length(crack_mode_)

end% function norm_crack_mode_ = normalse_crack_modes(Block_DATA.crack_mode_,normalising_mode_pair)

function [score_table,log_lik_table, rank_table,within_range_table,std_dist_table, predict_tag,LL_tag] = get_tag_scores (Score_vals,labels,mode_pairs_to_Use,Tags_,std_bar_size,include_LL)

%log_lik_table   --   to be created


score_mat = zeros( length(Score_vals.Means_) , length(mode_pairs_to_Use) + 1 );
mean_mat = score_mat;
std_mat = score_mat;


% for index = 1 :length(Score_vals.Means_)
% Score_vals.Stds_{index})
% end
for index = 1 :length(Score_vals.Means_)
temp_ =  100 * abs((Score_vals.Means_{index}-Score_vals.spec_vals_ ));
% temp_ =   abs((Score_vals.Means_{index}-Score_vals.spec_vals_ )./Score_vals.Stds_{index});
score_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)

if include_LL == 1
for index = 1 :length(Score_vals.Means_)
temp_ = round(100*abs(log( Score_vals.Stds_{index}.*pdf('Normal',Score_vals. spec_vals_ , Score_vals.Means_{index},Score_vals.Stds_{index}))))/100;
log_lik(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)
end %if include_LL == 1


for index = 1 :length(Score_vals.Means_)
temp_ =  Score_vals.Means_{index};
mean_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)

for index = 1 :length(Score_vals.Means_)
temp_ =  Score_vals.Stds_{index};
std_mat(index,:) = [temp_,mean(temp_)];
end % for index = 1 :length(Score_vals.Means_)



std_within_range_mat = Score_vals.spec_vals_ <= mean_mat(:,1:end-1)+std_bar_size*std_mat(:,1:end-1) & Score_vals.spec_vals_ >= mean_mat(:,1:end-1)-std_bar_size*std_mat(:,1:end-1);
std_within_range_mat = [std_within_range_mat,mean(std_within_range_mat,2)];

std_dist_mat = abs((mean_mat(:,1:end-1) - Score_vals.spec_vals_))  ./ std_mat(:,1:end-1);  

std_dist_mat = [std_dist_mat,mean(std_dist_mat,2)];

std_dist_mat =  round(std_dist_mat*100)/100; 


columns__ =  [labels(mode_pairs_to_Use),{'Mean'}];

[~ ,Predict_index]  =  min(score_mat(:,end));

predict_tag = Tags_{Predict_index};

score_table = array2table(score_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

if include_LL == 1
log_lik_table = array2table(log_lik,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 
[~ ,LL_indx]  =  min(log_lik(:,end));
LL_tag = Tags_{LL_indx};
else
log_lik_table = NaN;
LL_tag        = NaN;   
end %if include_LL == 1


within_range_table = array2table(std_within_range_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

std_dist_table = array2table(std_dist_mat,...
       'VariableNames',columns__,...
       'RowNames',Tags_); 

vals__   =  [1:length(Tags_)]'     ;
rank_mat =  zeros(size(score_mat)) ;


for index = 1: size(score_mat,2) - 1

if  sum(score_mat(:,index)) == 0
% do nothing
else    
[~,b_] = sort(score_mat(:,index),'ascend');
dumb     = score_mat(:,index); 
dumb(b_) =  vals__ ;
rank_mat(:,index) = dumb;
end %if  sum(score_mat(:,index)) == 0

end  % for index = 1: size(score_mat,2)



for index = 1: size(rank_mat,1)
rank_mat(index,size(rank_mat,2)) =  sum(rank_mat(index,1:size(rank_mat,2)-1))/(size(rank_mat,2)-1); 
end %for index = 1: size(rank_mat,1)

rank_table = array2table(rank_mat   ,...
       'VariableNames',columns__      ,...
       'RowNames',Tags_); 

end %function Tag_scores_    = get_tag_scores (Score_vals);





function [Score_vals, plot_data ]  =  do_mean_std_plot(spec_vals_temp , Block_DATA , mode_pairs_to_Use,labels,std_bar_size,display_plots,file_name,block_file_)

plot_data.spec_vals_temp  = spec_vals_temp ;
plot_data.Block_DATA = Block_DATA ;
plot_data.mode_pairs_to_Use = mode_pairs_to_Use;
plot_data.labels = labels;
plot_data.std_bar_size = std_bar_size;
plot_data.display_plots = display_plots;
plot_data.file_name = file_name;
plot_data.block_file_ = block_file_;

if display_plots(2) ==1
figure
end% if display_plots(2) ==1

val_nos_tmp = 1:16;


if display_plots(2) ==1
   
xBlanks = zeros(1, length(mode_pairs_to_Use));
axes('XTick', 1: length(mode_pairs_to_Use), 'XLim', [0,length(mode_pairs_to_Use)+1 ], 'XTickLabel', labels(mode_pairs_to_Use));

file_name(find(file_name =='_')) = ' ';
block_file_(find(block_file_=='_')) = ' ';

title({['TEST:: ',file_name],['LB:: ',block_file_]})

hold on
end %if display_plots(2) ==1



for index = 1: length(Block_DATA.Labels_)
mean_temp         =  reshape (Block_DATA.mean_tag_modes_{index},1,numel(Block_DATA.mean_tag_modes_{index}));
SD_temp           =  reshape (Block_DATA.std_tag_modes_{index},1,numel(Block_DATA.std_tag_modes_{index}));


if display_plots(2) ==1
errorbar(val_nos_tmp(1:length(mode_pairs_to_Use)),mean_temp(mode_pairs_to_Use),SD_temp(mode_pairs_to_Use)*std_bar_size,':o')
end%if display_plots(2) ==1

Means_{index} = mean_temp(mode_pairs_to_Use);
Stds_{index}  = SD_temp(mode_pairs_to_Use);
end %for index = 1: length(Block_DATA.Labels_)

if display_plots(2) ==1
plot(val_nos_tmp(1:length(mode_pairs_to_Use)),spec_vals_temp(mode_pairs_to_Use),'s','markersize',14)
legend([Block_DATA.Labels_,{'TEST'}],'location','EastOutside');

end %if display_plots(2) ==1

Score_vals.Means_       =  Means_                              ;
Score_vals.Stds_        =  Stds_                               ; 
Score_vals.spec_vals_   =  spec_vals_temp(mode_pairs_to_Use)   ;

end %function do_mean_std_plot(spec_vals,Block_DATA)

function plot_interp_data(interp_data,title_,db_range) 
figure
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

end %function plot_interp_data(interp_data,options) 

function interp_data = get_interp_data(slice_data,grid_size_to_plot)
if grid_size_to_plot > 4
    x = linspace(1,4,grid_size_to_plot);
    y = linspace(1,4,grid_size_to_plot);
    [xi, yi] = meshgrid(x, y);
    interp_data = interp2([1:4],[1:4],slice_data,xi,yi);
else
    interp_data = slice_data;
end %if grid_size_to_plot > length(options.modes)

interp_data = [interp_data; zeros(1, size(interp_data, 2)) ]       ;
interp_data = [interp_data, zeros(size(interp_data,1), 1)  ]       ;
end % function interp_data = get_interp_data(slice_data,options,grid_size_to_plot)




